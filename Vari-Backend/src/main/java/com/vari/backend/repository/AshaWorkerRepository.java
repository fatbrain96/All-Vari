package com.vari.backend.repository;

import com.vari.backend.model.AshaWorker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AshaWorkerRepository extends JpaRepository<AshaWorker, Long> {
    Optional<AshaWorker> findByAshaIdAndPin(String ashaId, String pin);
    Optional<AshaWorker> findByAshaId(String ashaId);
    boolean existsByAshaId(String ashaId);
}
