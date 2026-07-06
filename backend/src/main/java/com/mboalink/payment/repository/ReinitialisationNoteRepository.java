package com.mboalink.payment.repository;

import com.mboalink.payment.entity.ReinitialisationNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface ReinitialisationNoteRepository extends JpaRepository<ReinitialisationNote, UUID> {
}