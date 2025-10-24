#!/usr/bin/env python3
import requests
import time
import sys
import boto3
from datetime import datetime
import concurrent.futures

class TrafficGenerator:
    def __init__(self, base_url, namespace="LoadTest"):
        self.base_url = base_url
        self.request_count = 0
        self.successful_requests = 0
        self.failed_requests = 0
        self.response_times = []
        self.notified_800 = False
        self.notified_1500 = False
        
        # Initialize CloudWatch client
        try:
            self.cloudwatch = boto3.client('cloudwatch')
            self.namespace = namespace
            print("✅ CloudWatch client initialized")
        except Exception as e:
            print(f"⚠️  CloudWatch initialization failed: {e}")
            self.cloudwatch = None
    
    def make_request(self, endpoint="hello"):
        start_time = time.time()
        try:
            response = requests.get(f"{self.base_url}/{endpoint}", timeout=5)
            response_time = time.time() - start_time
            self.request_count += 1
            self.successful_requests += 1
            self.response_times.append(response_time)
            return True, response_time, response.status_code
        except Exception as e:
            self.request_count += 1
            self.failed_requests += 1
            return False, time.time() - start_time, str(e)
    
    def send_metrics_to_cloudwatch(self, phase_name):
        if not self.cloudwatch:
            return
            
        try:
            # Calculate metrics
            success_rate = (self.successful_requests / self.request_count * 100) if self.request_count > 0 else 0
            avg_response_time = sum(self.response_times) / len(self.response_times) if self.response_times else 0
            max_response_time = max(self.response_times) if self.response_times else 0
            min_response_time = min(self.response_times) if self.response_times else 0
            
            metrics = [
                {
                    'MetricName': 'RequestCount',
                    'Value': self.request_count,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'SuccessfulRequests',
                    'Value': self.successful_requests,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'FailedRequests',
                    'Value': self.failed_requests,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'SuccessRate',
                    'Value': success_rate,
                    'Unit': 'Percent'
                },
                {
                    'MetricName': 'AverageResponseTime',
                    'Value': avg_response_time,
                    'Unit': 'Seconds'
                },
                {
                    'MetricName': 'MaxResponseTime',
                    'Value': max_response_time,
                    'Unit': 'Seconds'
                },
                {
                    'MetricName': 'MinResponseTime',
                    'Value': min_response_time,
                    'Unit': 'Seconds'
                }
            ]
            
            # Send metrics to CloudWatch
            self.cloudwatch.put_metric_data(
                Namespace=self.namespace,
                MetricData=[{
                    **metric,
                    'Timestamp': datetime.utcnow(),
                    'Dimensions': [
                        {
                            'Name': 'LoadTestPhase',
                            'Value': phase_name
                        },
                        {
                            'Name': 'TargetURL',
                            'Value': self.base_url
                        }
                    ]
                } for metric in metrics]
            )
            
            print(f"📊 Sent {len(metrics)} metrics to CloudWatch for {phase_name}")
            
        except Exception as e:
            print(f"❌ Failed to send metrics to CloudWatch: {e}")
    
    def generate_traffic(self, target_requests_per_second, duration_seconds, phase_name):
        # Reset metrics for this phase
        phase_start_count = self.request_count
        phase_response_times = []
        
        requests_per_minute = target_requests_per_second * 60
        duration_minutes = duration_seconds // 60
        
        print(f"\n📍 {phase_name}")
        print(f"🎯 Target: {target_requests_per_second} req/sec = {requests_per_minute} req/min")
        print(f"⏱️  Duration: {duration_seconds} seconds ({duration_minutes} minutes)")
        
        if requests_per_minute >= 800 and not self.notified_800:
            print("💡 This should trigger SCALE-UP (800+ req/min threshold)")
            self.notified_800 = True
        if requests_per_minute >= 1500 and not self.notified_1500:
            print("🔥 This should trigger MAX SCALE-UP (1500+ req/min threshold)")
            self.notified_1500 = True
        
        end_time = time.time() + duration_seconds
        phase_start = time.time()
        last_log_time = phase_start
        last_metric_time = phase_start
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=target_requests_per_second * 2) as executor:
            while time.time() < end_time:
                second_start = time.time()
                successful_this_second = 0
                failed_this_second = 0
                response_times_this_second = []
                
                # Submit all requests for this second concurrently
                futures = [executor.submit(self.make_request) for _ in range(target_requests_per_second)]
                
                # Process results
                for future in concurrent.futures.as_completed(futures):
                    success, response_time, status = future.result()
                    if success:
                        successful_this_second += 1
                        phase_response_times.append(response_time)
                    else:
                        failed_this_second += 1
                
                # Send metrics to CloudWatch every 30 seconds
                current_time = time.time()
                if current_time - last_metric_time >= 30:
                    self.send_metrics_to_cloudwatch(phase_name)
                    last_metric_time = current_time
                
                # Log progress every 30 seconds
                if current_time - last_log_time >= 30:
                    elapsed_phase = current_time - phase_start
                    current_rate = (self.request_count - phase_start_count) / (elapsed_phase / 60)
                    remaining = end_time - current_time
                    avg_response = sum(phase_response_times) / len(phase_response_times) if phase_response_times else 0
                    
                    print(f"📈 Rate: {current_rate:.0f} req/min | Success: {successful_this_second} | Fail: {failed_this_second} | Avg Resp: {avg_response:.3f}s | Remaining: {remaining:.0f}s")
                    last_log_time = current_time
                
                # Maintain 1-second intervals
                elapsed_second = time.time() - second_start
                if elapsed_second < 1.0 and time.time() < end_time:
                    time.sleep(1.0 - elapsed_second)
        
        # Send final metrics for this phase
        self.send_metrics_to_cloudwatch(phase_name + "_Final")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generator.py <CLB_URL> [duration_minutes]")
        print("Scaling thresholds:")
        print("  - 800+ requests/minute → Add 1 instance")
        print("  - 1500+ requests/minute → Add 2 instances") 
        print("  - <300 requests/minute for 3 minutes → Remove 1 instance")
        sys.exit(1)
    
    clb_url = f"http://{sys.argv[1]}"
    duration_minutes = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    
    print(f"🚀 Starting {duration_minutes} minute load test with CloudWatch metrics")
    print(f"🎯 Target: {clb_url}")
    print("=" * 50)
    
    generator = TrafficGenerator(clb_url)
    total_seconds = duration_minutes * 60
    
    # 8-minute pattern (2-4-2)
    if duration_minutes == 8:
        print("📋 Traffic Pattern: 2min Normal → 4min Scale-up → 2min Max")
        generator.generate_traffic(10, 120, "Phase1_Normal")
        generator.generate_traffic(15, 240, "Phase2_ScaleUp") 
        generator.generate_traffic(25, 120, "Phase3_MaxLoad")
    else:
        # Flexible timing
        phase_duration = total_seconds // 3
        generator.generate_traffic(10, phase_duration, "Phase1_Normal")
        generator.generate_traffic(15, phase_duration, "Phase2_ScaleUp")
        generator.generate_traffic(25, phase_duration, "Phase3_MaxLoad")
    
    # Send final overall metrics
    if generator.cloudwatch:
        generator.send_metrics_to_cloudwatch("Overall_Summary")
    
    print("=" * 50)
    print(f"🎉 Load test completed!")
    print(f"📊 Total requests: {generator.request_count}")
    print(f"✅ Successful: {generator.successful_requests}")
    print(f"❌ Failed: {generator.failed_requests}")
    print(f"📈 Success rate: {(generator.successful_requests/generator.request_count*100):.1f}%")
    print(f"📈 Average rate: {generator.request_count/duration_minutes:.0f} req/min")