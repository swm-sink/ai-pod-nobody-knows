#!/bin/bash
# Dual Explanation Validation Script
# Ensures educational dual explanations are present (Technical + Simple)

set -e

ERROR_COUNT=0
WARNING_COUNT=0

echo "🎓 Validating educational dual explanations..."

# Function to log errors
log_error() {
    echo "❌ ERROR: $1" >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Function to log warnings
log_warning() {
    echo "⚠️  WARNING: $1" >&2
    WARNING_COUNT=$((WARNING_COUNT + 1))
}

# Function to log success  
log_success() {
    echo "✅ $1"
}

# Function to check for technical explanations
check_technical_explanations() {
    local file="$1"
    local count=0
    
    # Look for technical explanation patterns
    count=$(grep -iE "(Technical:|technical-explanation|**Technical)**" "$file" | wc -l)
    
    if [[ $count -eq 0 ]]; then
        # Check for alternative technical patterns
        count=$(grep -iE "(technical.*:|from a technical|technically)" "$file" | wc -l)
        
        if [[ $count -eq 0 ]]; then
            log_error "No technical explanations found in $file"
            echo "    Expected patterns: 'Technical:', '**Technical**', '<technical-explanation>'"
            return 1
        else
            log_warning "Technical explanations found but not in standard format in $file"
        fi
    fi
    
    echo "    Found $count technical explanation(s)"
    return 0
}

# Function to check for simple explanations
check_simple_explanations() {
    local file="$1"
    local count=0
    
    # Look for simple explanation patterns
    count=$(grep -iE "(Simple:|simple-explanation|**Simple)**|like.*|think of.*as|imagine.*)" "$file" | wc -l)
    
    if [[ $count -eq 0 ]]; then
        log_error "No simple explanations found in $file"
        echo "    Expected patterns: 'Simple:', '**Simple**', '<simple-explanation>', 'like...', 'think of...'"
        return 1
    fi
    
    echo "    Found $count simple explanation(s)"
    return 0
}

# Function to check for learning value statements
check_learning_value() {
    local file="$1"
    local count=0
    
    # Look for learning value patterns
    count=$(grep -iE "(learning.*(value|outcome|objective)|teaches|helps you learn|this.*learn)" "$file" | wc -l)
    
    if [[ $count -eq 0 ]]; then
        log_warning "No explicit learning value statements found in $file"
        echo "    Consider adding: 'This helps you learn...', 'Learning value:', '<learning-outcomes>'"
    else
        echo "    Found $count learning value statement(s)"
    fi
    
    return 0
}

# Function to check for analogies and examples
check_analogies() {
    local file="$1"
    local count=0
    
    # Look for analogy patterns
    count=$(grep -iE "(like|similar to|think of.*as|imagine|it's like|analogous to)" "$file" | wc -l)
    
    if [[ $count -eq 0 ]]; then
        log_warning "No analogies or examples found in $file"
        echo "    Consider adding comparisons: 'like...', 'think of it as...', 'imagine...'"
    else
        echo "    Found $count analogy/example(s)"
    fi
    
    return 0
}

# Function to check dual explanation structure
check_dual_structure() {
    local file="$1"
    
    # Check for balanced explanations
    local tech_count=$(grep -iE "(Technical:|technical-explanation|**Technical)**" "$file" | wc -l)
    local simple_count=$(grep -iE "(Simple:|simple-explanation|**Simple)**" "$file" | wc -l)
    
    if [[ $tech_count -gt 0 ]] && [[ $simple_count -gt 0 ]]; then
        if [[ $((tech_count - simple_count)) -gt 2 ]] || [[ $((simple_count - tech_count)) -gt 2 ]]; then
            log_warning "Imbalanced explanations in $file (Technical: $tech_count, Simple: $simple_count)"
            echo "    Aim for roughly equal numbers of technical and simple explanations"
        fi
    fi
    
    return 0
}

# Function to validate educational content quality
validate_educational_content() {
    local file="$1"
    local file_errors=0
    
    echo "Validating educational content in: $file"
    
    # Skip certain file types
    if [[ "$file" == *"constants.xml" ]] || 
       [[ "$file" == *"/templates/"* ]] || 
       [[ "$file" == *"/archive/"* ]]; then
        echo "  Skipping constants/template/archive file"
        return 0
    fi
    
    # Check for required explanation patterns
    if ! check_technical_explanations "$file"; then
        file_errors=$((file_errors + 1))
    fi
    
    if ! check_simple_explanations "$file"; then
        file_errors=$((file_errors + 1))
    fi
    
    # Additional quality checks (warnings only)
    check_learning_value "$file"
    check_analogies "$file"
    check_dual_structure "$file"
    
    if [[ $file_errors -eq 0 ]]; then
        log_success "Educational validation passed for $file"
    fi
    
    return $file_errors
}

# Function to suggest improvements
suggest_improvements() {
    local file="$1"
    
    echo ""
    echo "💡 Improvement suggestions for $file:"
    echo "   Add technical explanations:"
    echo "     **Technical:** [Professional explanation with industry terminology]"
    echo ""
    echo "   Add simple explanations:"
    echo "     **Simple:** \"Think of it like...\" [Analogy-based explanation]"
    echo ""
    echo "   Add learning connection:"
    echo "     **Connection:** \"This helps you learn...\" [Learning value and transferable skills]"
    echo ""
}

# Main validation loop
for file in "$@"; do
    if [[ -f "$file" ]] && [[ "$file" == *.xml ]]; then
        if ! validate_educational_content "$file"; then
            suggest_improvements "$file"
        fi
    fi
done

# Final results
echo ""
echo "📊 Educational Validation Summary:"
echo "   Errors: $ERROR_COUNT"
echo "   Warnings: $WARNING_COUNT"

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 All educational dual explanation checks passed!"
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo "⚠️  Consider addressing $WARNING_COUNT warnings to improve educational value"
    fi
    exit 0
else
    echo "💥 Found $ERROR_COUNT educational content errors"
    echo ""
    echo "Educational Requirements:"
    echo "  ✅ Technical explanations using professional terminology"
    echo "  ✅ Simple explanations using analogies and everyday examples" 
    echo "  ✅ Learning value statements connecting to transferable skills"
    echo "  ✅ Balanced ratio of technical to simple explanations"
    echo ""
    echo "This ensures every concept teaches both 'the right way' and 'why it matters'"
    exit 1
fi