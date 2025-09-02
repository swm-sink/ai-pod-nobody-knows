from onboarding_guide import get_onboarding_guide

guide = get_onboarding_guide()

all_text = " ".join([
    guide["introduction"],
    " ".join([step.get("description", "") for step in guide["steps"]]),
    " ".join([" ".join(step.get("actions", [])) for step in guide["steps"]])
]).lower()

complex_terms = ["langgraph", "yaml", "json", "endpoint", "api key", "cli", "configuration"]

print("Text being analyzed:")
print(all_text[:200] + "...")
print("\nTerm counts:")
total = 0
for term in complex_terms:
    count = all_text.count(term)
    if count > 0:
        print(f"'{term}': {count}")
        total += count

print(f"\nTotal: {total}")