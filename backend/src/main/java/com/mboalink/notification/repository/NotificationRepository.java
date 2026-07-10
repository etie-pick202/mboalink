package com.mboalink.notification.repository;

import com.mboalink.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> findByUtilisateurIdOrderByCreeLeDesc(UUID utilisateurId);

    long countByUtilisateurIdAndLuLeIsNull(UUID utilisateurId);

    List<Notification> findByUtilisateurIdAndLuLeIsNull(UUID utilisateurId);
}
