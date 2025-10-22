import requests
import threading
import time
import random

API_URL = "http://<YOUR-ELB-DNS-NAME>/api/hello"  # Replace with your ELB endpoint

def send_request():
    try:
        response = requests.get(API_URL, timeout=5)
        print(f"{response.status_code} - {response.text[:50]}")
    except Exception as e:
        print(f"Error: {e}")

def generate_load(rate_per_sec, duration):
    print(f"Generating traffic: {rate_per_sec} requests/sec for {duration} seconds")
    end_time = time.time() + duration
    while time.time() < end_time:
        threads = []
        for _ in range(rate_per_sec):
            t = threading.Thread(target=send_request)
            t.start()
            threads.append(t)
        time.sleep(1)
        for t in threads:
            t.join()

if __name__ == "__main__":
    # Step 1: Normal load (low traffic)
    generate_load(rate_per_sec=2, duration=120)

    # Step 2: High load (trigger scale-out)
    generate_load(rate_per_sec=30, duration=300)

    # Step 3: Back to normal (trigger scale-in)
    generate_load(rate_per_sec=2, duration=180)

    print("Traffic test completed.")
