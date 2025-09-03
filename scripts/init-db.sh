#!/bin/bash
# ------------------------------------------
# Initialize PostgreSQL for SwiftTrack
# ------------------------------------------

# DB credentials (match .env)
DB_USER=${POSTGRES_USER:-postgres}
DB_PASSWORD=${POSTGRES_PASSWORD:-example}
DB_NAME=${POSTGRES_DB:-swiftlog}

echo "Initializing PostgreSQL database: $DB_NAME"

# Create tables 
docker exec -i swift_postgres psql -U $DB_USER -d $DB_NAME <<EOF
-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    vehicle_type VARCHAR(50),
    capacity INT,
    max_distance INT
);

-- Routes table
CREATE TABLE IF NOT EXISTS routes (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    vehicle_id INT REFERENCES vehicles(id),
    route_data JSONB,
    optimized_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

echo "✅ PostgreSQL initialized."
