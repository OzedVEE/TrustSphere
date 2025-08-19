;; TrustSphere - Decentralized Trust and Credibility Network on Stacks
;; A comprehensive trust verification system that tracks participant credibility across multiple ecosystems

;; Constants
(define-constant ADMIN_PRINCIPAL tx-sender)
(define-constant ERR_ACCESS_DENIED (err u500))
(define-constant ERR_INVALID_SCORE (err u501))
(define-constant ERR_SELF_EVALUATION (err u502))
(define-constant ERR_PARTICIPANT_NOT_EXISTS (err u503))
(define-constant ERR_DUPLICATE_EVALUATION (err u504))
(define-constant ERR_INSUFFICIENT_DEPOSIT (err u505))

;; Minimum deposit required to submit evaluations (in microSTX)
(define-constant MIN_DEPOSIT_AMOUNT u2000000) ;; 2 STX

;; Data Variables
(define-data-var admin-principal principal ADMIN_PRINCIPAL)
(define-data-var total-participants uint u0)

;; Data Maps
(define-map participant-profiles 
    { participant: principal }
    {
        trust-score: uint,
        evaluation-count: uint,
        deposit-balance: uint,
        join-block: uint,
        verified-participant: bool
    }
)

(define-map trust-evaluations
    { evaluator: principal, evaluated-participant: principal }
    {
        score: uint,
        deposit-amount: uint,
        block-timestamp: uint,
        evaluation-type: (string-ascii 50)
    }
)

(define-map ecosystem-integrations
    { ecosystem: (string-ascii 50) }
    {
        integration-enabled: bool,
        trust-multiplier: uint,
        ecosystem-admin: principal
    }
)

;; Public Functions

;; Join the trust network as a new participant
(define-public (join-trust-network)
    (let ((caller tx-sender))
        (asserts! (is-none (map-get? participant-profiles { participant: caller })) ERR_ACCESS_DENIED)
        (map-set participant-profiles
            { participant: caller }
            {
                trust-score: u5000, ;; Start with neutral trust (5000 out of 10000)
                evaluation-count: u0,
                deposit-balance: u0,
                join-block: stacks-block-height,
                verified-participant: false
            }
        )
        (var-set total-participants (+ (var-get total-participants) u1))
        (ok true)
    )
)

;; Submit a trust evaluation for another participant
(define-public (submit-trust-evaluation (evaluated-participant principal) (score uint) (evaluation-type (string-ascii 50)))
    (let (
        (caller tx-sender)
        (deposit-balance (stx-get-balance caller))
    )
        ;; Validation checks
        (asserts! (not (is-eq caller evaluated-participant)) ERR_SELF_EVALUATION)
        (asserts! (and (>= score u1) (<= score u10)) ERR_INVALID_SCORE)
        (asserts! (>= deposit-balance MIN_DEPOSIT_AMOUNT) ERR_INSUFFICIENT_DEPOSIT)
        (asserts! (is-some (map-get? participant-profiles { participant: evaluated-participant })) ERR_PARTICIPANT_NOT_EXISTS)
        (asserts! (is-none (map-get? trust-evaluations { evaluator: caller, evaluated-participant: evaluated-participant })) ERR_DUPLICATE_EVALUATION)
        
        ;; Store the trust evaluation
        (map-set trust-evaluations
            { evaluator: caller, evaluated-participant: evaluated-participant }
            {
                score: score,
                deposit-amount: MIN_DEPOSIT_AMOUNT,
                block-timestamp: stacks-block-height,
                evaluation-type: evaluation-type
            }
        )
        
        ;; Update evaluated participant's profile
        (match (map-get? participant-profiles { participant: evaluated-participant })
            participant-data (begin
                (map-set participant-profiles
                    { participant: evaluated-participant }
                    {
                        trust-score: (calculate-updated-trust-score 
                            (get trust-score participant-data)
                            (get evaluation-count participant-data)
                            score
                        ),
                        evaluation-count: (+ (get evaluation-count participant-data) u1),
                        deposit-balance: (+ (get deposit-balance participant-data) MIN_DEPOSIT_AMOUNT),
                        join-block: (get join-block participant-data),
                        verified-participant: (get verified-participant participant-data)
                    }
                )
                true
            )
            false
        )
        
        ;; Ensure the participant profile was updated successfully
        (asserts! (match (map-get? participant-profiles { participant: evaluated-participant })
            participant-data true
            false
        ) ERR_PARTICIPANT_NOT_EXISTS)
        
        (ok true)
    )
)

;; Verify a participant profile (only admin or ecosystem admins)
(define-public (verify-participant (participant principal))
    (begin
        (asserts! (is-eq tx-sender (var-get admin-principal)) ERR_ACCESS_DENIED)
        (asserts! (is-some (map-get? participant-profiles { participant: participant })) ERR_PARTICIPANT_NOT_EXISTS)
        
        (match (map-get? participant-profiles { participant: participant })
            participant-data (begin
                (map-set participant-profiles
                    { participant: participant }
                    (merge participant-data { verified-participant: true })
                )
                true
            )
            false
        )
        
        ;; Ensure the participant profile was updated successfully
        (asserts! (is-some (map-get? participant-profiles { participant: participant })) ERR_PARTICIPANT_NOT_EXISTS)
        (ok true)
    )
)

;; Add or update ecosystem integration
(define-public (integrate-ecosystem (ecosystem (string-ascii 50)) (ecosystem-admin principal) (multiplier uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin-principal)) ERR_ACCESS_DENIED)
        (map-set ecosystem-integrations
            { ecosystem: ecosystem }
            {
                integration-enabled: true,
                trust-multiplier: multiplier,
                ecosystem-admin: ecosystem-admin
            }
        )
        (ok true)
    )
)

;; Private Functions

;; Calculate updated trust score using weighted average
(define-private (calculate-updated-trust-score (current-trust uint) (evaluation-count uint) (new-score uint))
    (let (
        (weighted-current (* current-trust evaluation-count))
        (scaled-new-score (* new-score u1000)) ;; Scale score to 1000-10000 range
        (updated-count (+ evaluation-count u1))
    )
        (/ (+ weighted-current scaled-new-score) updated-count)
    )
)

;; Read-only Functions

;; Get participant's trust profile
(define-read-only (get-participant-profile (participant principal))
    (map-get? participant-profiles { participant: participant })
)

;; Get trust evaluation between two participants
(define-read-only (get-trust-evaluation (evaluator principal) (evaluated-participant principal))
    (map-get? trust-evaluations { evaluator: evaluator, evaluated-participant: evaluated-participant })
)

;; Get total number of network participants
(define-read-only (get-total-participants)
    (var-get total-participants)
)

;; Check if participant profile is verified
(define-read-only (is-participant-verified (participant principal))
    (match (map-get? participant-profiles { participant: participant })
        participant-data (get verified-participant participant-data)
        false
    )
)

;; Get trust score as percentage (0-100)
(define-read-only (get-trust-percentage (participant principal))
    (match (map-get? participant-profiles { participant: participant })
        participant-data (/ (get trust-score participant-data) u100)
        u0
    )
)

;; Get ecosystem integration details
(define-read-only (get-ecosystem-info (ecosystem (string-ascii 50)))
    (map-get? ecosystem-integrations { ecosystem: ecosystem })
)