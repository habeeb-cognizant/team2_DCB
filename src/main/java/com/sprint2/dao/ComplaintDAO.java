package com.sprint2.dao;

import com.sprint2.DBConnection;
import com.sprint2.model.Complaint;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class ComplaintDAO {
    // This method now correctly uses complaint_seq and inserts into the right columns
    public void submitComplaint(Complaint complaint) {
        String sql = "INSERT INTO complaints (complaint_id, description, status, submitted_by, department_id, priority_level) VALUES (complaint_seq.NEXTVAL, ?, ?, 1, 1, 'Medium')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, complaint.getDescription());
            stmt.setString(2, complaint.getStatus());

            int rows = stmt.executeUpdate();
            System.out.println(rows + " row(s) inserted for new complaint.");
        } catch (SQLException exception) {
            System.err.println("Error submitting complaint: " + exception.getMessage());
        }
    }

    public void updateResponse(int complaintId, String newStatus) {
        String sql = "UPDATE complaints SET status = ? WHERE complaint_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, newStatus);
            stmt.setInt(2, complaintId);

            int rows = stmt.executeUpdate();
            System.out.println(rows + " row(s) updated by updateResponse.");
        } catch (SQLException exception) {
            System.err.println("Error updating complaint: " + exception.getMessage());
        }
    }

    public void escalateComplaint(int complaintId) {
        String sql = "UPDATE complaints SET escalated = 'Yes' WHERE complaint_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, complaintId);

            int rows = stmt.executeUpdate();
            System.out.println("Complaint escalated. Rows updated: " + rows);
        } catch (SQLException exception) {
            System.err.println("Error escalating complaint: " + exception.getMessage());
        }
    }
}
