package com.alumni.app.service;

import com.alumni.app.entity.MentorshipRequest;
import com.alumni.app.entity.User;
import com.alumni.app.enums.MentorshipStatus;
import com.alumni.app.repository.MentorshipRequestRepository;
import com.alumni.app.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import com.alumni.app.dto.DashboardSummaryDTO;
import com.alumni.app.dto.MentorshipRequestDTO;
import com.alumni.app.exception.InvalidStatusTransitionException;
import com.alumni.app.exception.ResourceNotFoundException;
import com.alumni.app.exception.UnauthorizedMentorException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Service
@RequiredArgsConstructor
public class MentorshipService {
    private final MentorshipRequestRepository requestRepository;
    private final UserRepository userRepository;

    public MentorshipRequestDTO submitRequest(MentorshipRequest request) {
        if (request.getId() == null) {
            request.setId(UUID.randomUUID().toString());
        }
        if (request.getStatus() == null) {
            request.setStatus(MentorshipStatus.pending);
        }
        
        // Ensure student exists
        if (request.getStudent() != null && request.getStudent().getId() != null) {
            User student = userRepository.findById(request.getStudent().getId())
                    .orElseGet(() -> userRepository.save(request.getStudent()));
            request.setStudent(student);
        }

        // For demo, if no mentor assigned, just save as is or assign first mentor
        // Usually, the mentorId comes from the form or logic.
        
        MentorshipRequest saved = requestRepository.save(request);
        return mapToDTO(saved);
    }

    public Page<MentorshipRequestDTO> getMentorRequests(String mentorId, MentorshipStatus status, Pageable pageable) {
        Page<MentorshipRequest> requests;
        if (status != null) {
            requests = requestRepository.findByMentorIdAndStatus(mentorId, status, pageable);
        } else {
            requests = requestRepository.findByMentorId(mentorId, pageable);
        }
        return requests.map(this::mapToDTO);
    }

    public MentorshipRequestDTO getRequestById(String id) {
        return requestRepository.findById(id)
                .map(this::mapToDTO)
                .orElseThrow(() -> new ResourceNotFoundException("Mentorship request not found with id: " + id));
    }

    public MentorshipRequestDTO updateStatus(String id, String mentorId, MentorshipStatus newStatus) {
        MentorshipRequest request = requestRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Mentorship request not found with id: " + id));

        // Ownership validation
        if (request.getMentor() == null || !request.getMentor().getId().equals(mentorId)) {
            throw new UnauthorizedMentorException("You are not authorized to update this request");
        }

        // Status transition logic
        if (request.getStatus() != MentorshipStatus.pending) {
            throw new InvalidStatusTransitionException("Status can only be changed from PENDING. Current status: " + request.getStatus());
        }

        if (newStatus != MentorshipStatus.accepted && newStatus != MentorshipStatus.rejected) {
            throw new InvalidStatusTransitionException("Invalid target status. Must be ACCEPTED or REJECTED.");
        }

        request.setStatus(newStatus);
        return mapToDTO(requestRepository.save(request));
    }

    public DashboardSummaryDTO getDashboardSummary(String mentorId) {
        return DashboardSummaryDTO.builder()
                .pendingCount(requestRepository.countByMentorIdAndStatus(mentorId, MentorshipStatus.pending))
                .acceptedCount(requestRepository.countByMentorIdAndStatus(mentorId, MentorshipStatus.accepted))
                .rejectedCount(requestRepository.countByMentorIdAndStatus(mentorId, MentorshipStatus.rejected))
                .build();
    }

    private MentorshipRequestDTO mapToDTO(MentorshipRequest request) {
        if (request == null) return null;
        
        String studentName = (request.getStudent() != null) ? request.getStudent().getName() : "Unknown Student";
        
        return MentorshipRequestDTO.builder()
                .id(request.getId())
                .studentName(studentName)
                .message(request.getReason())
                .status(request.getStatus())
                .createdAt(request.getCreatedAt())
                .updatedAt(request.getUpdatedAt())
                .build();
    }
}
