package com.mboalink.admin.repository;

import com.mboalink.payment.entity.Notation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotationRepository extends JpaRepository<Notation, UUID> {

    List<Notation> findByNoteLessThanOrderByCreeLeDesc(Integer note);

    long countByNoteLessThan(Integer note);
}