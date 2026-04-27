-- Create ASHA Worker table
CREATE TABLE IF NOT EXISTS asha_worker (
    id BIGSERIAL PRIMARY KEY,
    asha_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    assigned_village VARCHAR(255),
    phone VARCHAR(20),
    age INTEGER,
    block VARCHAR(255),
    pin VARCHAR(255),
    first_login BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Health Report table
CREATE TABLE IF NOT EXISTS health_report (
    id BIGSERIAL PRIMARY KEY,
    asha_id VARCHAR(50) NOT NULL,
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    water_ph DOUBLE PRECISION,
    water_tds DOUBLE PRECISION,
    water_turbidity DOUBLE PRECISION,
    water_safety VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (asha_id) REFERENCES asha_worker(asha_id)
);

-- Create Victim table
CREATE TABLE IF NOT EXISTS victim (
    id BIGSERIAL PRIMARY KEY,
    health_report_id BIGINT NOT NULL,
    name VARCHAR(255),
    age INTEGER,
    gender VARCHAR(50),
    disease VARCHAR(255),
    duration VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (health_report_id) REFERENCES health_report(id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_asha_worker_asha_id ON asha_worker(asha_id);
CREATE INDEX IF NOT EXISTS idx_health_report_asha_id ON health_report(asha_id);
CREATE INDEX IF NOT EXISTS idx_victim_health_report_id ON victim(health_report_id);
