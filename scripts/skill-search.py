#!/usr/bin/env python3
"""
Skill Search Tool - Find the right skill for any task

Usage:
    skill-search.py <query>           # Search by keyword
    skill-search.py --category <cat>  # List skills in category
    skill-search.py --use-case <uc>   # Find skills for use case
    skill-search.py --list            # List all categories
    skill-search.py --detail <skill>  # Show skill details
    skill-search.py --recommend <task> # Recommend skills for task
"""

import json
import os
import sys
import re
from pathlib import Path
from difflib import SequenceMatcher

SCRIPT_DIR = Path(__file__).parent
CATALOG_PATH = SCRIPT_DIR.parent / "memory" / "skills-catalog.json"
SKILLS_DIR = Path("/home/project/openclaw/skills")

def load_catalog():
    """Load the skills catalog."""
    if not CATALOG_PATH.exists():
        print(f"Error: Catalog not found at {CATALOG_PATH}", file=sys.stderr)
        sys.exit(1)
    with open(CATALOG_PATH) as f:
        return json.load(f)

def similarity(a, b):
    """Calculate similarity ratio between two strings."""
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()

def search_by_keyword(catalog, query):
    """Search skills by keyword in name, purpose, and description."""
    query = query.lower()
    results = []
    
    # Search in skill index
    for skill_name, info in catalog.get("skill_index", {}).items():
        score = 0
        matches = []
        
        # Name match (highest priority)
        if query in skill_name.lower():
            score += 10
            matches.append(f"name: {skill_name}")
        
        # Purpose match
        purpose = info.get("purpose", "")
        if purpose and query in purpose.lower():
            score += 5
            matches.append(f"purpose: {purpose}")
        
        # Subcategory match
        subcat = info.get("subcategory", "")
        if subcat and query in subcat.lower():
            score += 3
            matches.append(f"subcategory: {subcat}")
        
        # Category match
        category = info.get("category", "")
        if category and query in category.lower():
            score += 2
            matches.append(f"category: {category}")
        
        # Fuzzy match on name
        if score == 0:
            fuzzy_score = similarity(query, skill_name)
            if fuzzy_score > 0.5:
                score = int(fuzzy_score * 5)
                matches.append(f"fuzzy match ({fuzzy_score:.0%})")
        
        if score > 0:
            results.append({
                "skill": skill_name,
                "score": score,
                "matches": matches,
                "info": info
            })
    
    # Search in use case keywords
    for use_case, skills in catalog.get("use_case_keywords", {}).items():
        if query in use_case.lower():
            for skill in skills:
                for r in results:
                    if r["skill"] == skill:
                        r["score"] += 3
                        r["matches"].append(f"use case: {use_case}")
                        break
                else:
                    info = catalog["skill_index"].get(skill, {})
                    results.append({
                        "skill": skill,
                        "score": 5,
                        "matches": [f"use case: {use_case}"],
                        "info": info
                    })
    
    return sorted(results, key=lambda x: x["score"], reverse=True)

def list_categories(catalog):
    """List all skill categories."""
    print("📚 SKILL CATEGORIES\n")
    for cat_name, cat_info in catalog.get("categories", {}).items():
        desc = cat_info.get("description", "")
        skills = cat_info.get("skills", {})
        if isinstance(skills, dict):
            # Check if nested (like app_automation)
            total = 0
            for subcat, skill_list in skills.items():
                if isinstance(skill_list, list):
                    total += len(skill_list)
                else:
                    total += 1
        else:
            total = len(skills)
        print(f"  {cat_name}: {total} skills")
        print(f"    {desc}\n")

def list_category_skills(catalog, category):
    """List all skills in a category."""
    cat_data = catalog.get("categories", {}).get(category)
    if not cat_data:
        print(f"Category '{category}' not found")
        return
    
    print(f"📁 {category.upper()}\n")
    print(f"  {cat_data.get('description', '')}\n")
    
    skills = cat_data.get("skills", {})
    if isinstance(skills, dict):
        for subcat, items in skills.items():
            print(f"  [{subcat}]")
            if isinstance(items, list):
                for skill in items:
                    info = catalog["skill_index"].get(skill, {})
                    purpose = info.get("purpose", "")
                    print(f"    • {skill}" + (f" - {purpose}" if purpose else ""))
            else:
                # It's a skill object with purpose
                print(f"    • {subcat}: {items.get('purpose', '')}")
            print()

def find_by_use_case(catalog, use_case):
    """Find skills for a specific use case."""
    use_case = use_case.lower().replace("-", "_").replace(" ", "_")
    
    # Direct match
    if use_case in catalog.get("use_case_keywords", {}):
        skills = catalog["use_case_keywords"][use_case]
        print(f"🎯 Skills for '{use_case}':\n")
        for skill in skills:
            info = catalog["skill_index"].get(skill, {})
            print(f"  • {skill}")
            if info.get("category"):
                print(f"    Category: {info['category']}")
            if info.get("purpose"):
                print(f"    Purpose: {info['purpose']}")
            print()
        return
    
    # Fuzzy search use cases
    print(f"No exact match for '{use_case}'. Similar use cases:\n")
    for uc in catalog.get("use_case_keywords", {}).keys():
        if use_case in uc or uc in use_case or similarity(use_case, uc) > 0.5:
            print(f"  • {uc}")

def get_skill_detail(skill_name):
    """Get detailed info about a skill by reading its SKILL.md."""
    skill_dir = SKILLS_DIR / skill_name
    skill_md = skill_dir / "SKILL.md"
    
    if not skill_md.exists():
        print(f"No SKILL.md found for '{skill_name}'")
        return
    
    print(f"📄 {skill_name}\n")
    print(f"Path: {skill_dir}\n")
    
    with open(skill_md) as f:
        content = f.read()
    
    # Extract frontmatter
    if content.startswith("---"):
        parts = content.split("---", 2)
        if len(parts) >= 3:
            frontmatter = parts[1].strip()
            body = parts[2].strip()
            
            print("Metadata:")
            for line in frontmatter.split("\n"):
                if ":" in line:
                    print(f"  {line}")
            print("\n" + "─" * 50 + "\n")
            
            # Show first part of body
            lines = body.split("\n")
            preview = "\n".join(lines[:50])
            print(preview)
            if len(lines) > 50:
                print(f"\n... ({len(lines) - 50} more lines)")
    else:
        print(content[:2000])
        if len(content) > 2000:
            print(f"\n... ({len(content) - 2000} more chars)")

def recommend_for_task(catalog, task):
    """Recommend skills based on task description."""
    task = task.lower()
    results = []
    
    # Keyword mapping for task types
    task_keywords = {
        "email|mail|send.*message": ["send_email", "email"],
        "issue|ticket|bug|task": ["create_issue", "manage_tasks"],
        "slack|discord|chat|message": ["post_message"],
        "database|sheet|table": ["database"],
        "pay|charge|bill|invoice": ["payments"],
        "calendar|schedule|meeting|event": ["calendar"],
        "file|upload|download|storage": ["file_storage"],
        "crm|contact|lead|deal": ["crm", "business"],
        "post|tweet|social|linkedin": ["social_media"],
        "analytics|track|metrics|dashboard": ["analytics"],
        "deploy|ci|cd|pipeline": ["devops_ci"],
        "design|figma|ui|visual": ["design", "visual"],
        "code|develop|build|implement": ["coding"],
        "test|verify|check": ["coding"],
        "organize|cleanup|sort": ["organization"],
        "skill|create.*skill": ["skill_meta"],
        "changelog|release|notes": ["content"],
        "video|youtube|download": ["visual"],
        "image|photo|enhance": ["visual"],
    }
    
    matched_use_cases = set()
    for pattern, use_cases in task_keywords.items():
        if re.search(pattern, task):
            matched_use_cases.update(use_cases)
    
    # Get skills for matched use cases
    for uc in matched_use_cases:
        if uc in catalog.get("use_case_keywords", {}):
            for skill in catalog["use_case_keywords"][uc]:
                info = catalog["skill_index"].get(skill, {})
                results.append({
                    "skill": skill,
                    "use_case": uc,
                    "category": info.get("category", ""),
                    "purpose": info.get("purpose", "")
                })
    
    # Also do keyword search
    search_results = search_by_keyword(catalog, task)
    for r in search_results[:5]:
        if not any(res["skill"] == r["skill"] for res in results):
            results.append({
                "skill": r["skill"],
                "use_case": "keyword match",
                "category": r["info"].get("category", ""),
                "purpose": r["info"].get("purpose", "")
            })
    
    print(f"💡 Recommendations for: '{task}'\n")
    if not results:
        print("  No matching skills found. Try different keywords.")
        return
    
    seen = set()
    for r in results[:10]:
        if r["skill"] in seen:
            continue
        seen.add(r["skill"])
        print(f"  ⭐ {r['skill']}")
        if r.get("category"):
            print(f"     Category: {r['category']}")
        if r.get("purpose"):
            print(f"     Purpose: {r['purpose']}")
        print(f"     Matched via: {r['use_case']}")
        print()

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)
    
    catalog = load_catalog()
    
    args = sys.argv[1:]
    
    if args[0] == "--list":
        list_categories(catalog)
    elif args[0] == "--category" and len(args) > 1:
        list_category_skills(catalog, args[1])
    elif args[0] == "--use-case" and len(args) > 1:
        find_by_use_case(catalog, args[1])
    elif args[0] == "--detail" and len(args) > 1:
        get_skill_detail(args[1])
    elif args[0] == "--recommend" and len(args) > 1:
        recommend_for_task(catalog, " ".join(args[1:]))
    elif args[0].startswith("--"):
        print(f"Unknown option: {args[0]}")
        print(__doc__)
    else:
        # Default: keyword search
        query = " ".join(args)
        results = search_by_keyword(catalog, query)
        
        print(f"🔍 Search results for: '{query}'\n")
        if not results:
            print("  No results found.")
        else:
            for r in results[:15]:
                print(f"  [{r['score']}] {r['skill']}")
                for m in r["matches"][:2]:
                    print(f"         → {m}")
                print()

if __name__ == "__main__":
    main()
