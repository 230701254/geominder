# backend/hillclimbing_logic.py
import math, random

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = math.sin(dLat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dLon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c * 1000  # in meters


def hill_climb(current_lat, current_lon, target_lat, target_lon):
    current_distance = calculate_distance(current_lat, current_lon, target_lat, target_lon)

    for _ in range(100):
        new_lat = current_lat + random.uniform(-0.0001, 0.0001)
        new_lon = current_lon + random.uniform(-0.0001, 0.0001)
        new_distance = calculate_distance(new_lat, new_lon, target_lat, target_lon)

        if new_distance < current_distance:
            current_lat, current_lon, current_distance = new_lat, new_lon, new_distance

    return {
        "optimized_lat": current_lat,
        "optimized_lon": current_lon,
        "optimized_distance": current_distance
    }
