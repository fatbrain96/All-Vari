-- Create ASHA Worker table
CREATE TABLE IF NOT EXISTS asha_workers (
    id BIGSERIAL PRIMARY KEY,
    asha_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    assigned_village VARCHAR(255),
    phone VARCHAR(20),
    age INTEGER,
    block VARCHAR(255),
    pin VARCHAR(255),
    is_first_login BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Health Report table
CREATE TABLE IF NOT EXISTS health_reports (
    id BIGSERIAL PRIMARY KEY,
    asha_id VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    image_url VARCHAR(255),
    ph_level DOUBLE PRECISION,
    tds_level DOUBLE PRECISION,
    turbidity DOUBLE PRECISION,
    location VARCHAR(255),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Victim table
CREATE TABLE IF NOT EXISTS victims (
    id BIGSERIAL PRIMARY KEY,
    report_id BIGINT NOT NULL,
    name VARCHAR(255),
    age INTEGER,
    gender VARCHAR(50),
    disease VARCHAR(255),
    duration VARCHAR(100),
    weight DOUBLE PRECISION,
    contact_number VARCHAR(20),
    symptom_days INTEGER,
    patient_image_url VARCHAR(255),
    has_prior_medication BOOLEAN,
    prior_medication_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES health_reports(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_asha_workers_asha_id ON asha_workers(asha_id);
CREATE INDEX IF NOT EXISTS idx_health_reports_asha_id ON health_reports(asha_id);
CREATE INDEX IF NOT EXISTS idx_victims_report_id ON victims(report_id);
