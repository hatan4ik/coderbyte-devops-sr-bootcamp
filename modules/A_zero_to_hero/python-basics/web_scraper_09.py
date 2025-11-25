#!/usr/bin/env python3
"""Web Scraper - Simple web scraping with requests and BeautifulSoup"""

import requests
import sys
from urllib.parse import urljoin, urlparse

def scrape_website(url):
    if not url:
        print("Usage: python web_scraper_09.py <url>")
        return
    
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching URL: {e}")
        return
    
    try:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract basic information
        title = soup.find('title')
        links = soup.find_all('a', href=True)
        images = soup.find_all('img', src=True)
        
        print(f"Title: {title.text.strip() if title else 'No title'}")
        print(f"Links found: {len(links)}")
        print(f"Images found: {len(images)}")
        
        print("\nFirst 10 links:")
        for i, link in enumerate(links[:10]):
            href = urljoin(url, link['href'])
            text = link.text.strip()[:50]
            print(f"  {i+1}. {text} -> {href}")
            
    except ImportError:
        print("BeautifulSoup not available, showing raw content length")
        print(f"Content length: {len(response.content)} bytes")
        print(f"Content type: {response.headers.get('content-type', 'unknown')}")

if __name__ == "__main__":
    scrape_website(sys.argv[1] if len(sys.argv) > 1 else None)