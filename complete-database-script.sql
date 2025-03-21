-- Create the database
CREATE DATABASE IF NOT EXISTS `rms_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `rms_db`;

-- Drop existing tables if they exist (in reverse order of creation to handle foreign key constraints)
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `activity_log`;
DROP TABLE IF EXISTS `settings`;
DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `feedback`;
DROP TABLE IF EXISTS `notes`;
DROP TABLE IF EXISTS `interviews`;
DROP TABLE IF EXISTS `resume_data`;
DROP TABLE IF EXISTS `applications`;
DROP TABLE IF EXISTS `candidates`;
DROP TABLE IF EXISTS `jobs`;
DROP TABLE IF EXISTS `companies`;
DROP TABLE IF EXISTS `auth_permissions_users`;
DROP TABLE IF EXISTS `auth_permissions`;
DROP TABLE IF EXISTS `auth_groups_users`;
DROP TABLE IF EXISTS `auth_groups`;
DROP TABLE IF EXISTS `auth_tokens`;
DROP TABLE IF EXISTS `auth_logins`;
DROP TABLE IF EXISTS `auth_identities`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS=1;

-- Users table (this will integrate with Shield)
CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `status` varchar(255) NULL DEFAULT NULL,
  `status_message` varchar(255) NULL DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `last_active` datetime NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth identities table (for Shield - email/password)
CREATE TABLE `auth_identities` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NULL DEFAULT NULL,
  `secret` varchar(255) NOT NULL,
  `secret2` varchar(255) NULL DEFAULT NULL,
  `expires` datetime NULL DEFAULT NULL,
  `extra` text NULL DEFAULT NULL,
  `force_reset` tinyint(1) NOT NULL DEFAULT 0,
  `last_used_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type_secret` (`type`, `secret`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `auth_identities_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth logins table (for Shield)
CREATE TABLE `auth_logins` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(255) NOT NULL,
  `user_agent` varchar(255) NULL DEFAULT NULL,
  `id_type` varchar(255) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `user_id` int(11) UNSIGNED NULL DEFAULT NULL,
  `date` datetime NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_type_identifier` (`id_type`, `identifier`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth tokens table (for Shield)
CREATE TABLE `auth_tokens` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `selector` varchar(255) NOT NULL,
  `hashedValidator` varchar(255) NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `expires` datetime NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `selector` (`selector`),
  KEY `auth_tokens_user_id_foreign` (`user_id`),
  CONSTRAINT `auth_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth groups table (for Shield roles)
CREATE TABLE `auth_groups` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth groups_users table (for Shield - linking users to roles)
CREATE TABLE `auth_groups_users` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `group` varchar(255) NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auth_groups_users_user_id_foreign` (`user_id`),
  CONSTRAINT `auth_groups_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth permissions table (for Shield)
CREATE TABLE `auth_permissions` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auth permissions_users table (for Shield)
CREATE TABLE `auth_permissions_users` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `permission` varchar(255) NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auth_permissions_users_user_id_foreign` (`user_id`),
  CONSTRAINT `auth_permissions_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Companies table
CREATE TABLE `companies` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `user_id` int(11) UNSIGNED NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `companies_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Jobs table
CREATE TABLE `jobs` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `company_id` int(11) UNSIGNED NOT NULL,
  `description` text NOT NULL,
  `requirements` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `type` enum('full-time','part-time','contract','internship') NOT NULL DEFAULT 'full-time',
  `category` varchar(100) DEFAULT NULL,
  `salary_min` decimal(10,2) DEFAULT NULL,
  `salary_max` decimal(10,2) DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `status` enum('draft','published','closed') NOT NULL DEFAULT 'draft',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  CONSTRAINT `jobs_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Candidates table
CREATE TABLE `candidates` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `headline` varchar(255) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `resume_file` varchar(255) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `candidates_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Applications table
CREATE TABLE `applications` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_id` int(11) UNSIGNED NOT NULL,
  `candidate_id` int(11) UNSIGNED NOT NULL,
  `cover_letter` text DEFAULT NULL,
  `resume_file` varchar(255) DEFAULT NULL,
  `status` enum('applied','screening','interviewing','offered','hired','rejected') NOT NULL DEFAULT 'applied',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `job_id` (`job_id`),
  KEY `candidate_id` (`candidate_id`),
  CONSTRAINT `applications_job_id_foreign` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `applications_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Resume data table (for parsed resume data)
CREATE TABLE `resume_data` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `candidate_id` int(11) UNSIGNED NOT NULL,
  `skills` text DEFAULT NULL,
  `education` text DEFAULT NULL,
  `experience` text DEFAULT NULL,
  `languages` text DEFAULT NULL,
  `certifications` text DEFAULT NULL,
  `parsed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `candidate_id` (`candidate_id`),
  CONSTRAINT `resume_data_candidate_id_foreign` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Interviews table
CREATE TABLE `interviews` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `application_id` int(11) UNSIGNED NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `duration` int(11) NOT NULL DEFAULT 60 COMMENT 'Duration in minutes',
  `type` enum('phone','video','in-person') NOT NULL DEFAULT 'video',
  `location` varchar(255) DEFAULT NULL,
  `meeting_link` varchar(255) DEFAULT NULL,
  `interviewer_notes` text DEFAULT NULL,
  `candidate_notes` text DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled','rescheduled') NOT NULL DEFAULT 'scheduled',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `interviews_application_id_foreign` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notes table (for general notes on applications, candidates, etc.)
CREATE TABLE `notes` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED NOT NULL,
  `notable_type` varchar(255) NOT NULL COMMENT 'candidates, applications, etc.',
  `notable_id` int(11) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `notable_type_notable_id` (`notable_type`, `notable_id`),
  CONSTRAINT `notes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Feedback table (for interview feedback)
CREATE TABLE `feedback` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `interview_id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `rating` int(11) NOT NULL DEFAULT 0,
  `strengths` text DEFAULT NULL,
  `weaknesses` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `recommendation` enum('strong_yes', 'yes', 'maybe', 'no', 'strong_no') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `interview_id` (`interview_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `feedback_interview_id_foreign` FOREIGN KEY (`interview_id`) REFERENCES `interviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Messages table (for internal communication)
CREATE TABLE `messages` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) UNSIGNED NOT NULL,
  `receiver_id` int(11) UNSIGNED NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `related_type` varchar(255) DEFAULT NULL COMMENT 'applications, interviews, etc.',
  `related_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`),
  KEY `related_type_related_id` (`related_type`, `related_id`),
  CONSTRAINT `messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_receiver_id_foreign` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Settings table
CREATE TABLE `settings` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Activity log table
CREATE TABLE `activity_log` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(11) UNSIGNED DEFAULT NULL,
  `loggable_type` varchar(255) DEFAULT NULL,
  `loggable_id` int(11) UNSIGNED DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `loggable_type_loggable_id` (`loggable_type`, `loggable_id`),
  CONSTRAINT `activity_log_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default user groups
INSERT INTO `auth_groups` (`name`, `description`) VALUES
('admin', 'Administrator with full access'),
('recruiter', 'Recruiters who manage job postings and candidates'),
('employer', 'Employers who post jobs and review applications'),
('candidate', 'Job seekers who apply for positions');

-- Insert default permissions
INSERT INTO `auth_permissions` (`name`, `description`) VALUES
('jobs.create', 'Create job postings'),
('jobs.read', 'View job postings'),
('jobs.update', 'Update job postings'),
('jobs.delete', 'Delete job postings'),
('applications.create', 'Create applications'),
('applications.read', 'View applications'),
('applications.update', 'Update applications'),
('applications.delete', 'Delete applications'),
('candidates.read', 'View candidate profiles'),
('candidates.update', 'Update candidate profiles'),
('interviews.create', 'Schedule interviews'),
('interviews.read', 'View interview details'),
('interviews.update', 'Update interview details'),
('interviews.delete', 'Cancel interviews'),
('reports.view', 'View reports and analytics'),
('settings.manage', 'Manage system settings');

-- ========================
-- SAMPLE DATA FOR TESTING
-- ========================

-- Sample users (passwords would normally be hashed, but using placeholders here)
INSERT INTO `users` (`id`, `username`, `status`, `status_message`, `active`, `last_active`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'online', 'Working on system updates', 1, NOW(), NOW(), NOW()),
(2, 'recruiter1', 'online', 'Reviewing applications', 1, NOW(), NOW(), NOW()),
(3, 'employer1', 'away', 'In meetings', 1, NOW(), NOW(), NOW()),
(4, 'candidate1', 'offline', NULL, 1, NOW(), NOW(), NOW()),
(5, 'candidate2', 'offline', NULL, 1, NOW(), NOW(), NOW()),
(6, 'candidate3', 'online', 'Looking for new opportunities', 1, NOW(), NOW(), NOW());

-- Sample auth identities (for login)
INSERT INTO `auth_identities` (`user_id`, `type`, `name`, `secret`, `last_used_at`, `created_at`, `updated_at`) VALUES
(1, 'email_password', 'admin@example.com', 'admin_password_hash', NOW(), NOW(), NOW()),
(2, 'email_password', 'recruiter@example.com', 'recruiter_password_hash', NOW(), NOW(), NOW()),
(3, 'email_password', 'employer@techcorp.com', 'employer_password_hash', NOW(), NOW(), NOW()),
(4, 'email_password', 'john.doe@example.com', 'candidate1_password_hash', NOW(), NOW(), NOW()),
(5, 'email_password', 'jane.smith@example.com', 'candidate2_password_hash', NOW(), NOW(), NOW()),
(6, 'email_password', 'bob.johnson@example.com', 'candidate3_password_hash', NOW(), NOW(), NOW());

-- Assign users to groups
INSERT INTO `auth_groups_users` (`user_id`, `group`, `created_at`) VALUES
(1, 'admin', NOW()),
(2, 'recruiter', NOW()),
(3, 'employer', NOW()),
(4, 'candidate', NOW()),
(5, 'candidate', NOW()),
(6, 'candidate', NOW());

-- Sample companies
INSERT INTO `companies` (`name`, `description`, `website`, `email`, `phone`, `address`, `city`, `state`, `country`, `status`, `user_id`, `created_at`, `updated_at`) VALUES
('TechCorp', 'A leading technology company', 'https://techcorp.example.com', 'info@techcorp.example.com', '555-123-4567', '123 Tech Street', 'San Francisco', 'CA', 'USA', 'active', 3, NOW(), NOW()),
('Global Solutions', 'International consulting firm', 'https://globalsolutions.example.com', 'contact@globalsolutions.example.com', '555-987-6543', '456 Global Avenue', 'New York', 'NY', 'USA', 'active', 2, NOW(), NOW()),
('Innovative Designs', 'Creative design agency', 'https://innovative.example.com', 'hello@innovative.example.com', '555-456-7890', '789 Design Blvd', 'Los Angeles', 'CA', 'USA', 'active', 3, NOW(), NOW());

-- Sample jobs
INSERT INTO `jobs` (`title`, `company_id`, `description`, `requirements`, `location`, `type`, `category`, `salary_min`, `salary_max`, `deadline`, `status`, `created_at`, `updated_at`) VALUES
('Senior Software Engineer', 1, 'We are looking for an experienced software engineer to join our team.', 'Minimum 5 years experience with Java, Spring Boot, and React', 'San Francisco, CA', 'full-time', 'Engineering', 120000.00, 150000.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'published', NOW(), NOW()),
('UX Designer', 3, 'Join our creative team to design user experiences for our clients.', 'Experience with Figma and user research', 'Los Angeles, CA', 'full-time', 'Design', 90000.00, 110000.00, DATE_ADD(CURDATE(), INTERVAL 45 DAY), 'published', NOW(), NOW()),
('Project Manager', 2, 'Manage client projects from inception to delivery.', 'PMP certification preferred, minimum 3 years experience', 'New York, NY', 'full-time', 'Management', 85000.00, 110000.00, DATE_ADD(CURDATE(), INTERVAL 60 DAY), 'published', NOW(), NOW()),
('Frontend Developer', 1, 'Build responsive web applications using modern JavaScript frameworks.', 'Experience with React, Vue, or Angular', 'Remote', 'full-time', 'Engineering', 80000.00, 115000.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'published', NOW(), NOW()),
('Marketing Specialist', 3, 'Develop and execute marketing campaigns for our clients.', 'Background in digital marketing and social media', 'Los Angeles, CA', 'part-time', 'Marketing', 50000.00, 65000.00, DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'published', NOW(), NOW());

-- Sample candidates
INSERT INTO `candidates` (`user_id`, `first_name`, `last_name`, `email`, `phone`, `address`, `city`, `state`, `country`, `headline`, `summary`, `created_at`, `updated_at`) VALUES
(4, 'John', 'Doe', 'john.doe@example.com', '555-111-2222', '789 First St', 'Boston', 'MA', 'USA', 'Senior Developer with 7+ years experience', 'Full-stack developer specializing in JavaScript and Python.', NOW(), NOW()),
(5, 'Jane', 'Smith', 'jane.smith@example.com', '555-333-4444', '456 Second Ave', 'Chicago', 'IL', 'USA', 'UI/UX Designer & Frontend Developer', 'Creating beautiful and functional user interfaces for 5+ years.', NOW(), NOW()),
(6, 'Bob', 'Johnson', 'bob.johnson@example.com', '555-555-6666', '123 Third Blvd', 'Austin', 'TX', 'USA', 'Project Manager with Agile experience', 'Certified Scrum Master with experience leading diverse teams.', NOW(), NOW());

-- Sample resume data
INSERT INTO `resume_data` (`candidate_id`, `skills`, `education`, `experience`, `languages`, `certifications`, `parsed_at`, `created_at`, `updated_at`) VALUES
(1, 'JavaScript, React, Node.js, Python, MongoDB, AWS', 'Bachelor of Computer Science, MIT, 2015', '{"jobs":[{"title":"Senior Developer","company":"Previous Inc.","duration":"2018-2023"},{"title":"Web Developer","company":"First Digital","duration":"2015-2018"}]}', 'English, Spanish', 'AWS Certified Developer', NOW(), NOW(), NOW()),
(2, 'UI/UX Design, Figma, Sketch, HTML, CSS, JavaScript', 'BFA in Graphic Design, RISD, 2017', '{"jobs":[{"title":"UI Designer","company":"Design Agency","duration":"2019-2023"},{"title":"Graphic Designer","company":"Creative Co.","duration":"2017-2019"}]}', 'English, French', 'Certified UX Designer', NOW(), NOW(), NOW()),
(3, 'Project Management, Agile, Scrum, Jira, Confluence, Budgeting', 'MBA, University of Texas, 2016', '{"jobs":[{"title":"Project Manager","company":"Enterprise Solutions","duration":"2018-2023"},{"title":"Assistant PM","company":"Tech Initiatives","duration":"2016-2018"}]}', 'English', 'PMP, CSM', NOW(), NOW(), NOW());

-- Sample applications
INSERT INTO `applications` (`job_id`, `candidate_id`, `cover_letter`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'I am excited to apply for the Senior Software Engineer position...', 'screening', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(2, 2, 'As a UX Designer with 5 years of experience...', 'interviewing', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
(3, 3, 'My background in project management makes me a perfect fit...', 'applied', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(4, 1, 'I would like to express my interest in the Frontend Developer position...', 'applied', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(2, 1, 'Although my background is in development, I have significant experience in UX...', 'rejected', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

-- Sample interviews
INSERT INTO `interviews` (`application_id`, `scheduled_at`, `duration`, `type`, `location`, `meeting_link`, `interviewer_notes`, `status`, `created_at`, `updated_at`) VALUES
(1, DATE_ADD(NOW(), INTERVAL 3 DAY), 60, 'video', NULL, 'https://meeting.example.com/interview1', 'Focus on system design and architecture questions', 'scheduled', NOW(), NOW()),
(2, DATE_ADD(NOW(), INTERVAL 2 DAY), 45, 'video', NULL, 'https://meeting.example.com/interview2', 'Review portfolio and discuss design process', 'scheduled', NOW(), NOW()),
(2, DATE_SUB(NOW(), INTERVAL 5 DAY), 30, 'phone', NULL, NULL, 'Initial screening call completed. Candidate shows promise.', 'completed', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

-- Sample feedback
INSERT INTO `feedback` (`interview_id`, `user_id`, `rating`, `strengths`, `weaknesses`, `notes`, `recommendation`, `created_at`, `updated_at`) VALUES
(3, 2, 4, 'Strong visual design skills. Clear communication.', 'Could improve knowledge of user research methodologies.', 'Would be a good addition to the team.', 'yes', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

-- Sample notes
INSERT INTO `notes` (`user_id`, `notable_type`, `notable_id`, `content`, `created_at`, `updated_at`) VALUES
(2, 'candidates', 1, 'John demonstrated strong problem-solving skills during our call.', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(2, 'applications', 2, 'Portfolio includes impressive work for major brands.', DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
(3, 'applications', 3, 'Need to verify project management certification.', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY));

-- Sample messages
INSERT INTO `messages` (`sender_id`, `receiver_id`, `subject`, `content`, `is_read`, `related_type`, `related_id`, `created_at`, `updated_at`) VALUES
(2, 3, 'Candidate for Senior Developer position', 'I found a promising candidate for the Senior Developer role. Let\'s schedule a meeting to discuss.', 1, 'applications', 1, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(3, 2, 'Re: Candidate for Senior Developer position', 'Sounds good. I\'m available tomorrow afternoon.', 1, 'applications', 1, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
(2, 1, 'System update required', 'We need to update the candidate filtering system.', 0, NULL, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY));

-- Sample activity log
INSERT INTO `activity_log` (`user_id`, `loggable_type`, `loggable_id`, `action`, `description`, `ip_address`, `created_at`) VALUES
(2, 'applications', 1, 'status_update', 'Changed status from "applied" to "screening"', '192.168.1.1', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(2, 'applications', 2, 'status_update', 'Changed status from "screening" to "interviewing"', '192.168.1.1', DATE_SUB(NOW(), INTERVAL 8 DAY)),
(3, 'jobs', 1, 'create', 'Created new job posting', '192.168.1.2', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(4, 'applications', 1, 'create', 'Submitted application', '192.168.1.3', DATE_SUB(NOW(), INTERVAL 12 DAY));

-- Sample settings
INSERT INTO `settings` (`key`, `value`, `created_at`, `updated_at`) VALUES
('company_name', 'Recruitment Management System', NOW(), NOW()),
('email_notifications', 'true', NOW(), NOW()),
('default_pagination', '25', NOW(), NOW()),
('maintenance_mode', 'false', NOW(), NOW());
