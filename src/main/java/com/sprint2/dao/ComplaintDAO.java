package com.sprint2.dao;

import com.sprint2.DBConnection;
import com.sprint2.model.Complaint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class ComplaintDAO {

    private static final Logger logger = LoggerFactory.getLogger(ComplaintDAO.class);

    public void submitComplaint(Complaint complaint) {
        String sql = "INSERT INTO complaints (description, status) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, complaint.getDescription());
            stmt.setString(2, complaint.getStatus());

            int rows = stmt.executeUpdate();
            logger.info("{} row(s) inserted. Complaint submitted: {}", rows, complaint.getDescription());

        } catch (SQLException e) {
            logger.error("Error submitting complaint: {}", e.getMessage());
        }
    }

    public void updateResponse(int complaintId, String newStatus) {
        String sql = "UPDATE complaints SET status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, newStatus);
            stmt.setInt(2, complaintId);

            int rows = stmt.executeUpdate();
            logger.info("Complaint ID {} updated to status '{}'. Rows affected: {}", complaintId, newStatus, rows);

        } catch (SQLException e) {
            logger.error("Error updating complaint status: {}", e.getMessage());
        }
    }

    public void escalateComplaint(int complaintId) {
        String sql = "UPDATE complaints SET escalated = 'Yes' WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, complaintId);

            int rows = stmt.executeUpdate();
            logger.warn("Complaint ID {} escalated. Rows affected: {}", complaintId, rows);

        } catch (SQLException e) {
            logger.error("Error escalating complaint: {}", e.getMessage());
        }
    }
}
