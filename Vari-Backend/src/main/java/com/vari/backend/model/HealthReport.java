package com.vari.backend.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "health_reports")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HealthReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // --- ONE-TO-MANY RELATIONSHIP ---
    // One Report can have Many Victims
    @OneToMany(mappedBy = "healthReport", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // This allows the list to be sent in JSON
    private List<Victim> victims = new ArrayList<>();

    // --- OTHER FIELDS ---
    @Column(name = "asha_id")
    private String ashaId;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "ph_level")
    private Double phLevel;

    @Column(name = "tds_level")
    private Double tdsLevel;

    @Column(name = "turbidity")
    private Double turbidity;

    @Column(name = "location")
    private String location;

    @Column(name = "status")
    private String status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}