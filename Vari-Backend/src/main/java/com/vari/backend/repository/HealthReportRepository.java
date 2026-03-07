package com.vari.backend.repository;

import com.vari.backend.model.HealthReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HealthReportRepository extends JpaRepository<HealthReport, Long> {
    // No custom methods needed.
    // .save() and .findAll() are automatic!
}