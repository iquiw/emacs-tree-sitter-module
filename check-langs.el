(require 'treesit)

(let ((langs '(bash
               c
               c-sharp
               cmake
               cpp
               css
               dockerfile
               elixir
               gitattributes
               go
               gomod
               heex
               html
               java
               javascript
               jsdoc
               json
               lua
               markdown
               markdown-inline
               php
               phpdoc
               python
               ruby
               rust
               toml
               tsx
               typescript
               yaml))
      (buffer (get-buffer-create "*treesit langs result*")))
  (with-current-buffer buffer
    (read-only-mode -1)
    (erase-buffer)
    (let ((ok-count 0)
          (total 0))
      (dolist (lang langs)
        (setq total (1+ total))
        (let ((available (treesit-language-available-p lang)))
          (insert (if available
                      (progn
                        (setq ok-count (1+ ok-count))
                        (propertize (format "%3d: %s: available\n" total lang) 'face 'success))
                    (propertize (format "%3d: %s: no\n" total lang) 'face 'error)))))
      (insert (format "\nok/total: %d/%d" ok-count total)))
    (goto-char (point-min))
    (special-mode))
  (with-selected-window (get-buffer-window)
    (pop-to-buffer buffer)))
