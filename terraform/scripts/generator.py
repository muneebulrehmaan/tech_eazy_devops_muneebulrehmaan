#!/usr/bin/env python3
import requests
import time
import random
import threading
import sys
from datetime import datetime

class TrafficGenerator:
    def __init__(self, base_url):
        self.base_url = base_url
        self.request_count = 0
        
    def make_request(self, endpoint=""):
        try:
            url = f"{self.base_url}/{endpoint}"
            response = requests.get(url, timeout=10)
            self.request_count += 1
            print(f"[{datetime.now()}] Request {self.request_count}: Status {response.status_code}")
            return response.status_code
        except Exception as e:
            print(f"[{datetime.now()}] Request failed: {e}")
            return None
    
    def generate_normal_traffic(self, duration=300):
        """Generate normal traffic (1-2 requests per second)"""
        print(f"Generating normal traffic for {duration} seconds")
        end_time = time.time() + duration
        
        while time.time() < end_time:
            threads = []
            # 1-2 requests per second
            for _ in range(random.randint(1, 2)):
                thread = threading.Thread(target=self.make_request)
                threads.append(thread)
                thread.start()
            
            for thread in threads:
                thread.join()
            
            time.sleep(1)
    
    def generate_high_traffic(self, duration=600):
        """Generate high traffic (10-20 requests per second) to trigger scaling"""
        print(f"Generating high traffic for {duration} seconds")
        end_time = time.time() + duration
        
        while time.time() < end_time:
            threads = []
            # 10-20 requests per second
            for _ in range(random.randint(10, 20)):
                thread = threading.Thread(target=self.make_request)
                threads.append(thread)
                thread.start()
            
            for thread in threads:
                thread.join()
            
            time.sleep(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python traffic_generator.py <CLB_DNS_NAME>")
        sys.exit(1)
    
    clb_url = f"http://{sys.argv[1]}"
    generator = TrafficGenerator(clb_url)
    
    print("Starting traffic pattern:")
    print("1. Normal traffic for 5 minutes")
    print("2. High traffic for 10 minutes (should trigger scaling)")
    print("3. Normal traffic for 5 minutes (should scale down)")
    
    # Phase 1: Normal traffic
    generator.generate_normal_traffic(300)
    
    # Phase 2: High traffic
    generator.generate_high_traffic(600)
    
    # Phase 3: Back to normal
    generator.generate_normal_traffic(300)
    
    print("Traffic generation completed")