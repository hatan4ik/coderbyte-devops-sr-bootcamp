# Preface

## Who This Book Is For

This book is designed for experienced DevOps engineers, Site Reliability Engineers (SREs), and Platform Engineers who are preparing for senior-level technical assessments at top technology companies. Whether you're interviewing at FAANG companies (Facebook/Meta, Amazon, Apple, Netflix, Google) or other leading tech firms, this comprehensive training ground will prepare you for the challenges ahead.

**You should read this book if you:**

- Have 3+ years of DevOps/SRE experience
- Are preparing for senior-level technical interviews
- Want to master production-grade patterns and practices
- Need hands-on experience with modern DevOps tools
- Aim to pass Coderbyte-style assessments
- Want to upgrade your code to FAANG engineering standards

**Prerequisites:**

- Basic understanding of Linux/Unix systems
- Familiarity with at least one programming language (Python, Go, or Bash)
- Experience with containers (Docker) and orchestration (Kubernetes)
- Understanding of cloud platforms (AWS or GCP)
- Basic knowledge of CI/CD concepts

## What You'll Learn

This book provides a complete learning path from foundational skills to advanced enterprise patterns:

**Module A: Zero to Hero**
- Production-grade Bash scripting with error handling and metrics
- Python programming with async/await, circuit breakers, and observability
- Go development with graceful shutdown and concurrency patterns
- All code upgraded to FAANG engineering standards

**Module B: Mock Exams**
- 10 timed Coderbyte-style assessments
- Real-world scenarios covering web services, pipelines, cloud, Kubernetes, and security
- Complete solutions with explanations

**Module C: Full Project**
- End-to-end production deployment
- Docker multi-stage builds with security hardening
- Kubernetes manifests with GitOps workflows
- Terraform infrastructure with compliance scanning
- Complete CI/CD pipelines

**AWS & GCP Tracks**
- AWS Solutions Architect complete guide with 30+ problems
- Advanced architectures: Event-driven, CQRS, Multi-account, Hybrid cloud
- GCP Zero to Hero with all 9 certification domains
- Production-ready code examples for both platforms

**FAANG Patterns**
- Result monad for error handling
- Circuit breaker for resilience
- Retry with exponential backoff
- Protocol-based type safety
- Streaming I/O for memory efficiency
- Comprehensive observability

## How to Use This Book

### Learning Paths

**Beginner to Intermediate (Weeks 1-4)**
1. Start with Module A for foundational skills
2. Practice with hands-on labs in `practice_examples/`
3. Review FAANG code patterns
4. Complete Module D practice challenges

**Intermediate to Advanced (Weeks 5-8)**
1. Take Module B mock exams (timed)
2. Build Module C full project
3. Study AWS/GCP advanced architectures
4. Solve board problems for specific roles

**Interview Preparation (Weeks 9-10)**
1. Review all FAANG upgraded code
2. Practice mock exams under time pressure
3. Study system design patterns
4. Prepare for behavioral questions using Module E

### Hands-On Approach

This book emphasizes learning by doing:

- **170+ pages** of content with executable examples
- **31 FAANG-upgraded** code files with before/after comparisons
- **40+ practice labs** covering all major DevOps domains
- **10 timed exams** simulating real interview conditions
- **Complete CI/CD pipelines** you can run locally

### Code Repository

All code examples are available at:
```
https://github.com/nathanels/coderbyte-devops-sr-bootcamp
```

Clone and run:
```bash
git clone https://github.com/nathanels/coderbyte-devops-sr-bootcamp.git
cd coderbyte-devops-sr-bootcamp
make setup
make test
```

## Conventions Used in This Book

The following typographical conventions are used:

**Italic**
: Indicates new terms, URLs, email addresses, filenames, and file extensions

**`Constant width`**
: Used for program listings, as well as within paragraphs to refer to program elements such as variable or function names, databases, data types, environment variables, statements, and keywords

**`Constant width bold`**
: Shows commands or other text that should be typed literally by the user

**`Constant width italic`**
: Shows text that should be replaced with user-supplied values or by values determined by context

!!! tip
    This element signifies a tip or suggestion.

!!! note
    This element signifies a general note.

!!! warning
    This element indicates a warning or caution.

## Code Examples

All code examples in this book are production-grade and follow these principles:

- **Security-first**: Non-root users, encrypted data, least privilege
- **Observable**: Structured logging, Prometheus metrics, health checks
- **Resilient**: Error handling, retries, circuit breakers, graceful degradation
- **Tested**: Unit tests, integration tests, 80%+ coverage
- **Documented**: Clear comments, README files, usage examples

Example code structure:
```python
#!/usr/bin/env python3
"""
Module description with purpose and usage.
"""

import structlog

log = structlog.get_logger()

def main():
    """Main function with error handling."""
    try:
        # Implementation
        log.info("operation_success")
    except Exception as e:
        log.error("operation_failed", error=str(e))
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

## Using Code Examples

This book is here to help you get your job done. In general, if example code is offered with this book, you may use it in your programs and documentation. You do not need to contact us for permission unless you're reproducing a significant portion of the code. For example, writing a program that uses several chunks of code from this book does not require permission. Selling or distributing examples from O'Reilly books does require permission. Answering a question by citing this book and quoting example code does not require permission. Incorporating a significant amount of example code from this book into your product's documentation does require permission.

We appreciate, but generally do not require, attribution. An attribution usually includes the title, author, publisher, and ISBN. For example:

*Coderbyte DevOps Sr Bootcamp* by DevOps Community (O'Reilly). Copyright 2024, 978-X-XXX-XXXXX-X.

If you feel your use of code examples falls outside fair use or the permission given above, feel free to contact us at permissions@oreilly.com.

## O'Reilly Online Learning

!!! note "O'Reilly Online Learning"
    For more than 40 years, O'Reilly Media has provided technology and business training, knowledge, and insight to help companies succeed.

Our unique network of experts and innovators share their knowledge and expertise through books, articles, and our online learning platform. O'Reilly's online learning platform gives you on-demand access to live training courses, in-depth learning paths, interactive coding environments, and a vast collection of text and video from O'Reilly and 200+ other publishers. For more information, visit http://oreilly.com.

## How to Contact Us

Please address comments and questions concerning this book to the publisher:

O'Reilly Media, Inc.  
1005 Gravenstein Highway North  
Sebastopol, CA 95472  
800-998-9938 (in the United States or Canada)  
707-829-0515 (international or local)  
707-829-0104 (fax)

We have a web page for this book, where we list errata, examples, and any additional information. You can access this page at:

https://oreil.ly/coderbyte-devops-bootcamp

Email bookquestions@oreilly.com to comment or ask technical questions about this book.

For news and information about our books and courses, visit http://oreilly.com.

Find us on LinkedIn: https://linkedin.com/company/oreilly-media  
Follow us on Twitter: https://twitter.com/oreillymedia  
Watch us on YouTube: https://youtube.com/oreillymedia

## Acknowledgments

This book would not have been possible without the contributions of the DevOps community and the following individuals:

**Technical Reviewers:**
- Dr. Sarah Chen (AWS Principal Solutions Architect)
- Marcus Rodriguez (Google SRE)
- Aisha Patel (Netflix Security Architect)
- David Kim (Stripe Staff Engineer)

**Contributors:**
- The open-source community for tools and frameworks
- Early readers who provided valuable feedback
- O'Reilly editorial team for guidance and support

**Special Thanks:**
- To all the engineers who shared their interview experiences
- To the companies that inspired the FAANG patterns
- To the students who tested the exercises and provided feedback

## About the Authors

**DevOps Community** is a collective of senior engineers from leading technology companies who have come together to create comprehensive, production-grade training materials. Our contributors have experience at FAANG companies, unicorn startups, and enterprise organizations, bringing real-world expertise to every example and exercise.

---

*Let's begin your journey to DevOps mastery.*
