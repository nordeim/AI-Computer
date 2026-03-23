#!/usr/bin/env python3
"""
Test script to validate OpenRouter model configuration before applying changes.
Tests both models that will be added as fallbacks.
"""

import requests
import json
import sys

# OpenRouter API key from test_openrouter_model_4.py
OPENROUTER_KEY = "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"

MODELS_TO_TEST = [
    "nvidia/nemotron-3-super-120b-a12b:free",
    "stepfun/step-3.5-flash:free",
]

def test_model(model_id: str) -> dict:
    """Test a single model with a simple prompt."""
    headers = {
        "Authorization": f"Bearer {OPENROUTER_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    
    payload = {
        "model": model_id,
        "messages": [{"role": "user", "content": "Respond with just: OK"}],
        "max_tokens": 10,
        "stream": False,
    }
    
    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=payload,
            timeout=60
        )
        
        result = {
            "model": model_id,
            "status_code": response.status_code,
            "success": False,
            "content": None,
            "error": None
        }
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content")
            result["success"] = True
            result["content"] = content[:50] if content else "NO CONTENT"
        else:
            result["error"] = response.text[:200]
        
        return result
    except Exception as e:
        return {
            "model": model_id,
            "status_code": 0,
            "success": False,
            "content": None,
            "error": str(e)[:200]
        }

def test_openclaw_config_format():
    """Validate the config format matches OpenClaw expectations."""
    config_path = "/home/pete/.openclaw/openclaw.json"
    
    try:
        with open(config_path) as f:
            config = json.load(f)
    except Exception as e:
        return {"valid": False, "error": f"Failed to load config: {e}"}
    
    errors = []
    
    # Check openrouter provider exists
    providers = config.get("models", {}).get("providers", {})
    if "openrouter" not in providers:
        errors.append("openrouter provider not found in models.providers")
    else:
        or_config = providers["openrouter"]
        
        # Check required fields
        if "baseUrl" not in or_config:
            errors.append("openrouter missing baseUrl")
        elif not or_config["baseUrl"].startswith("https://"):
            errors.append(f"openrouter baseUrl should be HTTPS: {or_config['baseUrl']}")
        
        if "api" not in or_config:
            errors.append("openrouter missing api field")
        elif or_config["api"] not in ["openai-completions", "openai-responses"]:
            errors.append(f"openrouter api should be 'openai-completions': {or_config['api']}")
        
        if "models" not in or_config:
            errors.append("openrouter missing models array")
        else:
            for m in or_config["models"]:
                if "id" not in m:
                    errors.append(f"model missing id: {m}")
    
    # Check fallbacks
    fallbacks = config.get("agents", {}).get("defaults", {}).get("model", {}).get("fallbacks", [])
    for fb in fallbacks:
        if fb.startswith("openrouter/"):
            model_part = fb.replace("openrouter/", "")
            if model_part not in ["nvidia/nemotron-3-super-120b-a12b:free", "stepfun/step-3.5-flash:free"]:
                errors.append(f"unexpected fallback model: {fb}")
    
    return {
        "valid": len(errors) == 0,
        "errors": errors if errors else None,
        "provider_config": providers.get("openrouter", {}),
        "fallbacks": fallbacks
    }

def main():
    print("=" * 60)
    print("OpenRouter Configuration Test")
    print("=" * 60)
    
    # Test 1: API connectivity for each model
    print("\n1. Testing API connectivity for each model:\n")
    
    all_passed = True
    for model_id in MODELS_TO_TEST:
        result = test_model(model_id)
        status = "✓" if result["success"] else "✗"
        print(f"  {status} {model_id}")
        if result["success"]:
            print(f"      Response: {result['content']}")
        else:
            print(f"      Error: {result['error']}")
            all_passed = False
    
    # Test 2: Config format validation
    print("\n2. Validating OpenClaw config format:\n")
    
    config_result = test_openclaw_config_format()
    if config_result["valid"]:
        print("  ✓ Config format valid")
        print(f"      Fallbacks: {config_result['fallbacks']}")
    else:
        print("  ✗ Config format invalid:")
        for err in config_result.get("errors", []):
            print(f"      - {err}")
        all_passed = False
    
    # Summary
    print("\n" + "=" * 60)
    if all_passed:
        print("RESULT: ALL TESTS PASSED ✓")
        print("Configuration is ready for use.")
        return 0
    else:
        print("RESULT: SOME TESTS FAILED ✗")
        print("Review errors above before applying config.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
