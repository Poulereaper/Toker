# Toker — Rethinking Dating Through Your Interests

> **Final Year Project - PFE — CReATE / Data / Cyber Majors**
>
> A new generation of dating application that focuses on your interests rather than simple "swiping."

---

## Context

Current dating applications attract millions of users, but many express dissatisfaction.  
Suggested profiles rarely reflect true personality or actual interests, and algorithms too often prioritize appearance or popularity (Elo ranking).

**Connectly** starts from a simple observation: social networks are full of information about our tastes, passions, and values — all essential elements in creating authentic connections.  
The idea is therefore to **rethink dating** by using **likes, subscriptions, and appreciated content** on platforms like **TikTok** or **Instagram** to suggest truly compatible people.

---

## SMART Objectives

| Objective | Specific | Measurable | Appropriate | Realistic | Time-bound |
|-----------|----------|------------|-------------|-----------|------------|
| **Functional prototype** | Develop a dating application based on interests extracted from a social network | Enable a user to create a profile and get 5 relevant suggestions | Aligned with Data & Cyber skills | MVP achievable without full TikTok API access | December 2025 |
| **User validation** | Test the relevance of suggestions with a panel of users | 20 feedbacks, minimum 60% satisfaction | Confirms concept relevance | Internal testing feasible | January 2025 |
| **Legal & API framework** | Identify GDPR and technical constraints related to social data | 5-page documented report | Essential for project compliance | Feasible research with academic supervision | October 2025 |
| **Academic deliverables** | Write final report and present the project | Complete report (≥30 pages) + presentation | Consistent with PFE expectations | Achievable as a team | February 2026 |

---

## How the Concept Works

1. **Interest Data Collection**  
   - Retrieval (or simulation) of likes / categories / hashtags data from TikTok, Instagram, or X.
   - Anonymization and GDPR compliance.

2. **Hybrid Matching Algorithm**  
   - Combination of a similarity score based on interests and an Elo popularity score.
   - Adjustable weighting according to user preferences.

3. **User Interface (prototype)**  
   - Simple, mobile-first interface.  
   - Profile suggestions + affinity indicator.  
   - Basic "match" and messaging functionality (demo version).

---

## Technical Stack (provisional)

| Domain | Considered Technologies |
|--------|-------------------------|
| **Backend** | Python (FastAPI or Flask), REST API, SQLite/PostgreSQL |
| **Frontend** | React / Next.js, TailwindCSS |
| **Data / AI** | Python (scikit-learn, pandas, spaCy), similarity models |
| **Security** | Hashing (bcrypt), anonymization, GDPR compliance |
| **Testing / Deployment** | Docker, GitHub Actions |

---

## Ethical and Legal Framework

- No real user data will be collected without explicit consent.  
- TikTok or Instagram data will be **simulated** if access to the official API (Research API) is not validated.  
- The project is part of an **academic approach**, with no profit motive.  
- Compliance with **GDPR** and **CNIL** recommendations is guaranteed.

---

## Provisional Schedule

| Phase | Description | Deadline |
|-------|-------------|----------|
| **September–November 2025** | Documentary research + API / GDPR framework | December 1st |
| **December 2025-January 2026** | Prototype development | mid-January |
| **January 2026** | User testing + iterations | mid-January |
| **January 2026** | Finalization and corrections | January 31st |
| **February 2026** | Presentation and final report submission | February |

---

## Project Team

- Victor LAMBERT: Internet of Things (CReAT) victor.lambert@edu.ece.fr
- Karl LAVOCAT: Internet of Things (CReAT) karl.lavocat@edu.ece.fr
- Alexis RAYNAL: Cybersecurity alexis.raynal@edu.ece.fr
- Quentin RICHARD: Data & AI quentin.richard@edu.ece.fr
- SABBAGH Anthony: Data & AI anthony.sabbagh@edu.ece.fr
- Mathis GRAS: Cybersecurity mathis.gras@edu.ece.fr

---

## Launch the Project (MVP)
```bash
TO DO