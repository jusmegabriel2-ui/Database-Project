USE crownfield_eye_hospital;

SELECT
    c.clinician_id,
    c.full_name AS clinician_name,
    COUNT(a.appointment_id) AS total_appointments
FROM Clinician AS c
INNER JOIN Appointment AS a
    ON c.clinician_id = a.clinician_id
GROUP BY
    c.clinician_id,
    c.full_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY total_appointments DESC;

USE crownfield_eye_hospital;

SELECT
    a.appointment_id,
    p.full_name AS patient_name,
    c.full_name AS clinician_name,
    cl.clinic_name,
    a.appointment_date,
    a.appointment_time
FROM Appointment AS a
INNER JOIN Patient AS p
    ON a.patient_id = p.patient_id
INNER JOIN Clinician AS c
    ON a.clinician_id = c.clinician_id
INNER JOIN Clinic AS cl
    ON a.clinic_id = cl.clinic_id
ORDER BY
    a.appointment_date,
    a.appointment_time;

    USE crownfield_eye_hospital;

SELECT
    a.appointment_id,
    p.patient_id,
    p.full_name AS patient_name,
    a.appointment_date,
    a.appointment_time
FROM Appointment AS a
INNER JOIN Patient AS p
    ON a.patient_id = p.patient_id
LEFT JOIN Prescription AS pr
    ON a.appointment_id = pr.appointment_id
WHERE pr.prescription_id IS NULL
ORDER BY a.appointment_date;




USE crownfield_eye_hospital;

SELECT
    p.patient_id,
    p.full_name AS patient_name
FROM Patient AS p
WHERE p.patient_id IN (
    SELECT a.patient_id
    FROM Appointment AS a
    GROUP BY a.patient_id
    HAVING COUNT(a.appointment_id) > 1
)
ORDER BY p.full_name;


USE crownfield_eye_hospital;

DROP PROCEDURE IF EXISTS GetPatientAppointments;

DELIMITER $$

CREATE PROCEDURE GetPatientAppointments(
    IN requested_patient VARCHAR(12)
)
BEGIN
    SELECT
        a.appointment_id,
        p.full_name AS patient_name,
        c.full_name AS clinician_name,
        cl.clinic_name,
        a.appointment_date,
        a.appointment_time
    FROM Appointment AS a
    INNER JOIN Patient AS p
        ON a.patient_id = p.patient_id
    INNER JOIN Clinician AS c
        ON a.clinician_id = c.clinician_id
    INNER JOIN Clinic AS cl
        ON a.clinic_id = cl.clinic_id
    WHERE a.patient_id = requested_patient
    ORDER BY
        a.appointment_date,
        a.appointment_time;
END $$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER ValidateFollowUpInsert
BEFORE INSERT ON FollowUp
FOR EACH ROW
BEGIN
    DECLARE original_date DATE;

    SELECT appointment_date
    INTO original_date
    FROM Appointment
    WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < original_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Follow-up date cannot be before appointment date';
    END IF;
END $$

DELIMITER ;