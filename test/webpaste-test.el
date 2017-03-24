;;; webpaste --- Tests for webpaste
;;; Commentary:
;;; Code:
(require 'ert)
(require 'webpaste)



(ert-deftest webpaste--autopupulate-provider-priority ()
  "Test autopopulate of webpaste-provider-priority."

  (setq-default webpaste-provider-priority nil)
  (setq-default webpaste-providers-alist
                (list (list "provider1" "lamba")
                      (list "provider2" "lamba")
                      (list "provider3" "lamba")))

  (should (equal (webpaste--get-provider-priority)
                 '("provider1" "provider2" "provider3"))))



(ert-deftest webpaste--static-provider-priority ()
  "Test static configuration of webpaste-provider-priority."

  (setq-default webpaste-provider-priority
                '("provider2" "provider1" "provider3"))
  (setq-default webpaste-providers-alist '())

  (should (equal (webpaste--get-provider-priority)
                 '("provider2" "provider1" "provider3"))))



(ert-deftest webpaste--callback-from-working-provider ()
  "This test just sends a message to a good provider that just works."

  ;; Temporal storage for result
  (let ((returned-result nil))
    ;; Reset all webpaste variables
    (setq-default webpaste-tested-providers nil)
    (setq-default webpaste-provider-priority nil)

    ;; Make a fake provider that just "returns" the paste result by setting a
    ;; variable and concatinate it with "Works: " so we can see it showing up
    (setq-default webpaste-providers-alist
                  (list (list "workingprovider"
                              (lambda (text)
                                (setq returned-result
                                      (concat "Works: " text))))))

    ;; Call webpaste
    (webpaste-paste-text "test-string")

    ;; Check that we got the expected result
    (should (string= returned-result "Works: test-string"))))



(ert-deftest webpaste--callback-from-working-provider-as-fallback ()
  "This test sends a message to a bad provider that returns some error data.

Then the bad provider pastes again like it should and we check that we got the
result from the good provider only."

  ;; Temporal storage for result
  (let ((returned-result nil))
    ;; Reset all webpaste variables
    (setq-default webpaste-tested-providers nil)
    (setq-default webpaste-provider-priority nil)

    ;; Creates a "broken" provider that will call on the next provider due to a
    ;; faked failure and checks that the next provider is picked up correctly.
    (setq-default webpaste-providers-alist
                  (list (list "brokenprovider"
                              (lambda (text)
                                ;; Set return text
                                (setq returned-result
                                      (concat "Broken: " text))

                                ;; Call paste again
                                (webpaste-paste-text text)))

                        (list "workingprovider"
                              (lambda (text)
                                (setq returned-result
                                      (concat "Working: " text))))))

    ;; Call webpaste
    (webpaste-paste-text "test-string")

    ;; Check that we got the expected result
    (should (string= returned-result "Working: test-string"))))



(provide 'webpaste-test)
;;; webpaste-test.el ends here
