; 10 SYS2064

*=$0801

    BYTE    $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00
    
*=$0810

START                   SEI                             ; Set Interrupt disabled flag to prevent interrupts

                        LDA #$7F                        ; C64 has system set to recieve interrupts from CIA #1
                        STA $DC0D                       ; so we need to disable those 

                        LDA #<irq1                      ; Set lo-byte of 
                        STA $0314                       ; IRQ Vector
                        LDA #>irq1                      ; Set hi-byte on
                        STA $0315                       ; IRQ Vector
                        
                        LDA #$FA                        ; Set rasterline 
                        STA $D012                       ; where we want interrupt
                        LDA #$1B                        ; Set default value of $D011 with highest bit clear because 
                        STA $D011                       ; it serve as highest bit of rasterline (for lines 256 - ...)
                        
                        LDA #$00                        ; Lets clear last byte of gfx bank
                        STA $3FFF                       ; so we dont get black artefacts on borders
                        
                        LDA $DC0D                       ; Acknowledge CIA #1 interrupts incase they happened
                        LDA #$FF                        ; Acknowledge all VIC II
                        STA $D019                       ; interrupts
                        
                        LDA #$01                        ; And as LAST thing, enable raster interrupts on
                        STA $D01A                       ; VIC II 
                        
                        CLI                             ; Clear Interrupt disabled flag to allow interrupts again
                        
@waitSpace              LDA $DC01                       ; Check if 
                        AND #$10                        ; space is pressed?
                        BNE @waitSpace                  ; If not, keep waiting...

                        JMP $FCE2                       ; Reset C64...

irq1                    LDA $D011                       ; Load $D011
                        AND #$F7                        ; and clear bit #3 to
                        STA $D011                       ; set 24 rows mode

                        DEC $D020                       ; Lets change border color so we see "where we are"
                        
                        LDX #$10                        ; We need some delay before
@dummyDelay             DEX                             ; we can change 25 rows back, 
                        BNE @dummyDelay                 ; so lets loop and wait a bit...
                        
                        LDA $D011                       ; Load $D011
                        ORA #$08                        ; and set bit #3 to
                        STA $D011                       ; set 25 rows mode

                        INC $D020                       ; Lets change border color back...
                        
                        LDA #$FF                        ; Acknowledge all VIC II
                        STA $D019                       ; interrupts

                        JMP $EA81                       ; Jump to last part of KERNALs regular interrupt service routine
                    
                    