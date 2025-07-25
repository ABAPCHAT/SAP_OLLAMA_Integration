import os
import json
from flask import Flask, request, jsonify
import requests
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Ollama endpoint from environment variable
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3") # Default model

@app.route('/ollama_chat', methods=['POST'])
def ollama_chat():
    try:
        data = request.json
        # Assuming the ABAP report sends a list of key-value pairs
        prompt_data = {item['KEY']: item['VALUE'] for item in data}
        prompt = prompt_data.get('prompt')

        if not prompt:
            return jsonify({"error": "Prompt is missing"}), 400

        logging.info(f"Received prompt from SAP: {prompt}")

        # Prepare request for Ollama API
        ollama_request_body = {
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        }

        ollama_api_url = f"{OLLAMA_URL}/api/generate"

        # Call Ollama API
        ollama_response = requests.post(ollama_api_url, json=ollama_request_body)
        ollama_response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)

        ollama_response_json = ollama_response.json()
        response_text = ollama_response_json.get('response', 'No response from Ollama')

        logging.info(f"Ollama response: {response_text}")

        # Return response to SAP in a key-value pair list format
        return jsonify([{"KEY": "response", "VALUE": response_text}]), 200

    except requests.exceptions.RequestException as e:
        logging.error(f"Error communicating with Ollama: {e}")
        return jsonify({"error": f"Error communicating with Ollama: {e}"}), 500
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/ollama_models', methods=['GET'])
def ollama_models():
    try:
        ollama_tags_url = f"{OLLAMA_URL}/api/tags"
        ollama_response = requests.get(ollama_tags_url)
        ollama_response.raise_for_status()

        tags_data = ollama_response.json()
        models = tags_data.get('models', [])

        available_models = ", ".join([m['name'] for m in models])
        running_model = OLLAMA_MODEL # Assuming the configured model is the running one

        response_data = [
            {"KEY": "running_model", "VALUE": running_model},
            {"KEY": "available_models", "VALUE": available_models}
        ]
        return jsonify(response_data), 200

    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching Ollama models: {e}")
        return jsonify({"error": f"Error fetching Ollama models: {e}"}), 500
    except Exception as e:
        logging.error(f"Error processing models request: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # For development, run with: python main.py
    # For production, use a WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=5000)
