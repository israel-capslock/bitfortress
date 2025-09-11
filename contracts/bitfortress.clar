;; BitFortress Protocol
;;
;; Summary: Bitcoin-Native Liquid Staking with Fortress-Grade Security
;;
;; Description:
;; BitFortress transforms STX into productive Bitcoin-secured yield through an
;; innovative liquid staking protocol. Users deposit STX to earn compounding
;; rewards while maintaining liquidity through fortress tokens. The protocol
;; leverages Bitcoin's finality for unparalleled security, featuring dynamic
;; tier-based rewards, time-locked premium yields, and decentralized governance.
;;
;; Built on Stacks Layer 2, BitFortress combines Bitcoin's immutable security
;; with DeFi innovation, offering institutional-grade staking infrastructure
;; with retail accessibility. Governance participants shape protocol evolution
;; while earning enhanced rewards for their commitment to ecosystem growth.
;;
;; Core Features:
;; - Bitcoin-finalized security model with STX liquid staking rewards
;; - Dynamic tier system with escalating benefits for larger stakes
;; - Time-locked positions earning fortress premium rates up to 15% APY
;; - Liquid governance tokens enabling protocol parameter voting
;; - Emergency fortress mode with multi-signature protection mechanisms
;; - Adaptive withdrawal periods preventing cascading liquidation events
;;

;; Token Definitions
(define-fungible-token fortress-token u0)

;; Constants & Error Codes
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1000))
(define-constant ERR-INVALID-PARAMS (err u1001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1002))
(define-constant ERR-INSUFFICIENT-STX (err u1003))
(define-constant ERR-COOLDOWN-ACTIVE (err u1004))
(define-constant ERR-NO-POSITION (err u1005))
(define-constant ERR-BELOW-MINIMUM (err u1006))
(define-constant ERR-PROTOCOL-PAUSED (err u1007))

;; Protocol State Variables
(define-data-var protocol-paused bool false)
(define-data-var fortress-mode bool false)
(define-data-var total-stx-locked uint u0)
(define-data-var base-yield-rate uint u800) ;; 8% base APY (100 = 1%)
(define-data-var fortress-bonus-rate uint u200) ;; 2% fortress bonus
(define-data-var minimum-stake-amount uint u1000000) ;; 1 STX minimum
(define-data-var withdrawal-cooldown uint u1440) ;; 24hr cooldown blocks
(define-data-var active-proposals uint u0)

;; Data Structures

;; Governance Proposals
(define-map Proposals
  { proposal-id: uint }
  {
    proposer: principal,
    title: (string-utf8 128),
    description: (string-utf8 512),
    voting-start: uint,
    voting-end: uint,
    executed: bool,
    support-votes: uint,
    oppose-votes: uint,
    quorum-threshold: uint,
  }
)

;; User Staking Positions
(define-map StakingVaults
  principal
  {
    stx-deposited: uint,
    fortress-tokens: uint,
    tier-level: uint,
    lock-duration: uint,
    stake-timestamp: uint,
    last-reward-claim: uint,
    withdrawal-initiated: (optional uint),
    accumulated-yield: uint,
    governance-power: uint,
  }
)

;; Fortress Tier Configuration
(define-map FortressTiers
  uint
  {
    minimum-deposit: uint,
    yield-multiplier: uint,
    governance-weight: uint,
    premium-features: (list 5 bool),
  }
)

;; Private Helper Functions

(define-private (calculate-tier-level (deposit-amount uint))
  (if (>= deposit-amount u50000000) ;; 50 STX
    {
      tier: u4,
      multiplier: u250,
    } ;; Fortress Elite: 2.5x
    (if (>= deposit-amount u20000000) ;; 20 STX
      {
        tier: u3,
        multiplier: u200,
      } ;; Fortress Guardian: 2x
      (if (>= deposit-amount u5000000) ;; 5 STX
        {
          tier: u2,
          multiplier: u150,
        } ;; Fortress Builder: 1.5x
        {
          tier: u1,
          multiplier: u100,
        } ;; Fortress Basic: 1x
      )
    )
  )
)

(define-private (calculate-time-bonus (lock-duration uint))
  (if (>= lock-duration u17280)
    u175 ;; 12 months: 1.75x
    (if (>= lock-duration u8640)
      u150 ;; 6 months: 1.5x
      (if (>= lock-duration u4320)
        u125 ;; 3 months: 1.25x
        u100 ;; No lock: 1x
      )
    )
  )
)

(define-private (compute-staking-rewards
    (user principal)
    (blocks-elapsed uint)
  )
  (let (
      (vault (unwrap! (map-get? StakingVaults user) u0))
      (deposit-amount (get stx-deposited vault))
      (base-rate (var-get base-yield-rate))
      (tier-multiplier (get-tier-multiplier (get tier-level vault)))
      (time-bonus (calculate-time-bonus (get lock-duration vault)))
    )
    ;; Calculate: (deposit * rate * tier-multiplier * time-bonus * blocks) / annual-blocks
    (/
      (* (* (* (* deposit-amount base-rate) tier-multiplier) time-bonus)
        blocks-elapsed
      )
      u525600000
    )
  )
)

(define-private (get-tier-multiplier (tier uint))
  (let ((tier-config (map-get? FortressTiers tier)))
    (match tier-config
      config
      (get yield-multiplier config)
      u100 ;; Default 1x multiplier
    )
  )
)

(define-private (validate-lock-duration (duration uint))
  (or
    (is-eq duration u0) ;; Flexible staking
    (is-eq duration u4320) ;; 3 months
    (is-eq duration u8640) ;; 6 months
    (is-eq duration u17280) ;; 12 months
  )
)

(define-private (validate-proposal-params
    (title (string-utf8 128))
    (desc (string-utf8 512))
    (period uint)
  )
  (and
    (>= (len title) u5)
    (<= (len title) u128)
    (>= (len desc) u20)
    (<= (len desc) u512)
    (>= period u100) ;; Minimum 100 blocks
    (<= period u4320) ;; Maximum 3 days
  )
)