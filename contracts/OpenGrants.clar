;; =========================================================
;; OpenGrants Protocol (OGP)
;; A Decentralized Grants & Public-Goods Funding Smart Contract
;; Author: Nathaniel Matthew
;; License: MIT
;; =========================================================

(define-data-var contract-owner principal tx-sender)
(define-data-var grant-counter uint u0)
(define-data-var application-counter uint u0)

;; ---------------------------------------------------------
;; DATA STRUCTURES
;; ---------------------------------------------------------

;; Grant structure
(define-map grants
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    description-hash: (string-ascii 128),
    target-amount: uint,
    total-funded: uint,
    active: bool
  }
)

;; Application structure
(define-map applications
  { id: uint }
  {
    grant-id: uint,
    applicant: principal,
    proposal-hash: (string-ascii 128),
    requested: uint,
    approved: bool,
    paid: bool
  }
)

;; ---------------------------------------------------------
;; CONSTANTS & ERRORS
;; ---------------------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_ALREADY_APPROVED (err u103))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104))

;; ---------------------------------------------------------
;; FUNCTIONS
;; ---------------------------------------------------------

;; Create a new grant proposal
(define-public (create-grant (title (string-ascii 64)) (desc-hash (string-ascii 128)) (target uint))
  (let ((id (+ (var-get grant-counter) u1)))
    (begin
      (var-set grant-counter id)
      (map-set grants { id: id }
        {
          creator: tx-sender,
          title: title,
          description-hash: desc-hash,
          target-amount: target,
          total-funded: u0,
          active: true
        })
      (ok id)
    )
  )
)

;; Fund an existing grant
;; Added 'amount' parameter instead of using non-existent stx-get-transfer-amount function
(define-public (fund-grant (grant-id uint) (amount uint))
  (match (map-get? grants { id: grant-id })
    grant
      (let ((updated (+ (get total-funded grant) amount)))
        (begin
          (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
          (map-set grants { id: grant-id } (merge grant { total-funded: updated }))
          (ok updated)))
    ERR_NOT_FOUND)
)

;; Apply for a grant
(define-public (apply-grant (grant-id uint) (proposal-hash (string-ascii 128)) (requested uint))
  (let ((id (+ (var-get application-counter) u1)))
    (begin
      (var-set application-counter id)
      (map-set applications { id: id }
        {
          grant-id: grant-id,
          applicant: tx-sender,
          proposal-hash: proposal-hash,
          requested: requested,
          approved: false,
          paid: false
        })
      (ok id)
    )
  )
)

;; Approve an application
(define-public (approve-application (app-id uint))
  (let ((app (map-get? applications { id: app-id })))
    (match app
      application
        (let ((grant (map-get? grants { id: (get grant-id application) })))
          (match grant
            g
              (begin
                (asserts! (or (is-eq tx-sender (get creator g)) (is-eq tx-sender (var-get contract-owner))) ERR_UNAUTHORIZED)
                (map-set applications { id: app-id } (merge application { approved: true }))
                (ok true)
              )
            ERR_NOT_FOUND))
      ERR_NOT_FOUND)
  )
)

;; Disburse funds to approved applicant
(define-public (disburse-funds (app-id uint))
  (let ((app (map-get? applications { id: app-id })))
    (match app
      a
        (let ((grant (map-get? grants { id: (get grant-id a) })))
          (match grant
            g
              (begin
                (asserts! (get approved a) ERR_INVALID_INPUT)
                (asserts! (not (get paid a)) ERR_ALREADY_APPROVED)
                (asserts! (>= (get total-funded g) (get requested a)) ERR_INSUFFICIENT_FUNDS)
                (try! (stx-transfer? (get requested a) (as-contract tx-sender) (get applicant a)))
                (map-set grants { id: (get grant-id a) } (merge g { total-funded: (- (get total-funded g) (get requested a)) }))
                (map-set applications { id: app-id } (merge a { paid: true }))
                (ok true)
              )
            ERR_NOT_FOUND))
      ERR_NOT_FOUND)
  )
)

;; ---------------------------------------------------------
;; READ-ONLY FUNCTIONS
;; ---------------------------------------------------------

(define-read-only (get-grant (id uint))
  (map-get? grants { id: id })
)

(define-read-only (get-application (id uint))
  (map-get? applications { id: id })
)

(define-read-only (get-total-grants)
  (var-get grant-counter)
)

(define-read-only (get-total-applications)
  (var-get application-counter)
)

;; ---------------------------------------------------------
;; ADMIN FUNCTIONS
;; ---------------------------------------------------------

(define-public (pause-grant (grant-id uint))
  (let ((g (map-get? grants { id: grant-id })))
    (match g
      grant
        (begin
          (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
          (map-set grants { id: grant-id } (merge grant { active: false }))
          (ok true)
        )
      ERR_NOT_FOUND)
  )
)

;; ---------------------------------------------------------
;; END OF CONTRACT
;; ---------------------------------------------------------
