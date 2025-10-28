# backend/app.py
from flask import Flask, request, jsonify
from hillclimbing_logic import hill_climb

app = Flask(__name__)

@app.route('/optimize', methods=['POST'])
def optimize():
    data = request.json
    current_lat = data['current_lat']
    current_lon = data['current_lon']
    target_lat = data['target_lat']
    target_lon = data['target_lon']

    result = hill_climb(current_lat, current_lon, target_lat, target_lon)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
