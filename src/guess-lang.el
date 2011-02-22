;;; @(#) guess-lang.el --- Automagically guess what is the language of a buffer

;;; @(#) $Id: guess-lang.el,v 1.1 2001/04/24 20:18:11 drieu Exp drieu $

;; This file is *NOT* part of GNU Emacs.

;; Copyright (C) 2001 by Benjamin Drieu
;; Author:	 Benjamin Drieu <bdrieu@april.org>
;; Maintainer:	 Benjamin Drieu <bdrieu@april.org>
;; Created:	 2001-04-23
;; Keywords: languages, i18n

;; LCD Archive Entry:
;; guess-lang|Benjamin Drieu|bdrieu@april.org|
;; Automagically guess what is the language of a buffer|
;; 22-Apr-2001|$Revision: 1.1 $|~/misc/guess-lang.el|

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Automagically guess what is the language of a buffer.

;; This works basically by counting occurrences of common words in
;; every language that is known and comparing respective numbers.
;; Languages currently supported are english, french, german and
;; spanish.

;; guess-lang.el is based on a C program by Pascal Courtois
;; <Pascal.Courtois@nouvo.com>

;; Because ispell.el doesn't use hooks, guess-lang use is a little bit
;; tricky and ask you to add things like the two following examples in
;; your emacs initialization file.

;; (add-hook 'latex-mode-hook
;; 	  (lambda ()
;; 	    (ispell-change-dictionary (guess-lang-buffer))))

;; (add-hook 'message-send-hook
;; 	     (lambda ()
;; 	       (ispell-change-dictionary (guess-lang-message))
;; 	       (ispell-message)))

;; To do:
;; - explain how to make new ratio tables of keywords.
;; - speed up execution
;; - in case we check a huge buffer, only check a small part

;; History:

;; $Log: guess-lang.el,v $
;; Revision 1.1  2001/04/24 20:18:11  drieu
;; Initial revision
;;

;;; Variables:

(defvar guess-lang-version (substring "$Revision: 1.1 $" 11)
  "Version number.")

(defgroup guess-lang nil
  "Language automatic detection."
  :group 'i18n
  :group 'convenience)

(defcustom guess-languages-to-guess
  '("francais" "american")
  "Languages to guess.  Their names should be the same as Ispell dictionnaries you have."
  :type 'list
  :group 'guess-lang)

(defvar guess-lang-words
  '(
    ;; French is an alias for français
    ("french" . "fr_FR-lrg")
    ("francais" . "fr_FR-lrg")
    ("fr_FR-lrg" .
     (("de" . 0.038982874)
      ("la" . 0.026053034)
      ("et" . 0.015805825)
      ("le" . 0.015539979)
      ("les" . 0.015394974)
      ("des" . 0.013244028)
      ("a" . 0.012881505)
      ("en" . 0.011238087)
      ("un" . 0.008821295)
      ("est" . 0.008821295)
      ("il" . 0.008047921)
      ("que" . 0.007757904)
      ("du" . 0.007709569)
      ("une" . 0.006936195)
      ("dans" . 0.006356168)
      ("qui" . 0.005921146)
      ("pour" . 0.005510288)
      ("au" . 0.005147772)
      ("pas" . 0.004857755)
      ("s" . 0.004567738)
      ("sur" . 0.004471068)
      ("ne" . 0.004422733)
      ("par" . 0.004205222)
      ("ce" . 0.003987711)
      ("plus" . 0.003939376)
      ("se" . 0.003818535)
      ("ont" . 0.003141831)
      ("on" . 0.002948491)
      ("ou" . 0.002900149)
      ("sont" . 0.002851814)
      ("nous" . 0.002755144)
      ("mais" . 0.002634303)
      ("aux" . 0.002489298)
      ("e" . 0.002416792)
      ("me" . 0.002392628)
      ("ils" . 0.002344286)
      ("avec" . 0.002295951)
      ("son" . 0.002150946)
      ("je" . 0.002102611)
      ("y" . 0.00207844)
      ("cette" . 0.002005941)))
    
    ;; British is an alias for american
    ("british" . "american")
    ("american" .
     (("the" . 0.049920353)
      ("of" . 0.022687168)
      ("to" . 0.019041785)
      ("in" . 0.01741208)
      ("and" . 0.015953924)
      ("a" . 0.015053304)
      ("is" . 0.010635954)
      ("that" . 0.00896336)
      ("s" . 0.006733244)
      ("for" . 0.006261486)
      ("it" . 0.006089937)
      ("not" . 0.005661068)
      ("be" . 0.005618186)
      ("on" . 0.005017768)
      ("this" . 0.004631788)
      ("as" . 0.004588899)
      ("was" . 0.004503128)
      ("are" . 0.00441735)
      ("have" . 0.003945592)
      ("i" . 0.003859821)
      ("by" . 0.003816932)
      ("with" . 0.003816932)
      ("will" . 0.00377405)
      ("has" . 0.003473841)
      ("you" . 0.003388063)
      ("they" . 0.003302292)
      ("but" . 0.003216521)
      ("at" . 0.003173632)
      ("he" . 0.003044972)
      ("would" . 0.003002083)
      ("an" . 0.003002083)
      ("all" . 0.002959194)
      ("people" . 0.002873423)
      ("there" . 0.002873423)
      ("-" . 002787652)
      ("from" . 0.002701874)
      ("or" . 0.002616103)
      ("which" . 0.002573214)
      ("his" . 0.002487443)
      ("we" . 0.002487443)
      ("what" . 0.002358783)
      ("one" . 0.002273005)
      ("who" . 0.002230116)
      ("q" . 0.002015685)))

    ;; Espa~nol is an alias for spanish
    ("espa~nol" . "spanish")
    ("spanish" .
     (("de" . 0.044589881)
      ("a" . 0.029319374)
      ("la" . 0.027868673)
      ("que" . 0.023898343)
      ("el" . 0.019698952)
      ("n" . 0.018782722)
      ("en" . 0.018706373)
      ("y" . 0.018477312)
      ("los" . 0.012063702)
      ("un" . 0.009238656)
      ("se" . 0.008398775)
      ("del" . 0.007482545)
      ("no" . 0.00702443)
      ("s" . 0.006871725)
      ("su" . 0.006795376)
      ("con" . 0.006642671)
      ("por" . 0.006489966)
      ("una" . 0.00641361)
      ("las" . 0.0061082)
      ("es" . 0.006031851)
      ("lo" . 0.00549738)
      ("al" . 0.004962916)
      ("para" . 0.004657506)
      ("o" . 0.003893981)
      ("le" . 0.003817625)
      ("sus" . 0.00366492)
      ("ha" . 0.00366492)
      ("pero" . 0.003283161)
      ("como" . 0.003130456)
      ("me" . 0.002672341)
      ("os" . 0.00213787)
      ("cuando" . 0.002061521)
      ("ayer" . 0.001985165)
      ("ya" . 0.001985165)
      ("muy" . 0.001908816)
      ("dos" . 0.001756111)
      ("phoenix" . 0.001756111)
      ("an" . 0.001756111)
      ("sin" . 0.001450701)
      ("ser" . 0.001374345)
      ("entre" . 0.001297996)
      ("ante" . 0.00122164)
      ("fiz" . 0.00122164)
      ("fue" . 0.001145291)
      ("desde" . 0.001145291)
      ("era" . 0.001145291)
      ("cayetano" . 0.001145291)
      ("todo" . 0.001068935)
      ("sobre" . 0.001068935)))

    ;; German is an alias for deutsch
    ("german" . "deutsch")
    ("deutsch" .
     (("der" . 0.02616971)
      ("die" . 0.026090407)
      ("und" . 0.020777162)
      ("in" . 0.013798575)
      ("sie" . 0.010031721)
      ("den" . 0.00955591)
      ("das" . 0.008366379)
      ("er" . 0.007454398)
      ("mit" . 0.007295799)
      ("sich" . 0.006423473)
      ("dem" . 0.006383825)
      ("von" . 0.006145916)
      ("des" . 0.006066613)
      ("es" . 0.00598731)
      ("auf" . 0.005908007)
      ("ist" . 0.005789056)
      ("ein" . 0.005789056)
      ("nicht" . 0.005432196)
      ("zu" . 0.005233942)
      ("im" . 0.005194287)
      ("als" . 0.00455987)
      ("aber" . 0.00420301)
      ("r" . 0.004123714)
      ("eine" . 0.003885805)
      ("so" . 0.003409994)
      ("wie" . 0.003330691)
      ("an" . 0.003251388)
      ("auch" . 0.00321174)
      ("hat" . 0.003053134)
      ("aus" . 0.003053134)
      ("nach" . 0.002973831)
      ("war" . 0.002616971)
      ("ber" . 0.002537668)
      ("ihr" . 0.002458365)
      ("noch" . 0.002379062)
      ("-" . 002260111)
      ("sind" . 0.002101505)
      ("da" . 0.002061857)
      ("um" . 0.002061857)
      ("fin" . 0.002022202)
      ("nur" . 0.001982554)
      ("haben" . 0.001982554)
      ("einen" . 0.001942899)
      ("hatte" . 0.001903251)
      ("man" . 0.001903251)))

;    Sorry, comrades, I've found no Italian ispell dictionary
;    ("italian" .
;     (("di" . 0.030788156)
;      ("e" . 0.020181049)
;      ("il" . 0.017150448)
;      ("che" . 0.016289483)
;      ("la" . 0.013741021)
;      ("a" . 0.012019091)
;      ("in" . 0.010331594)
;      ("un" . 0.009815015)
;      ("per" . 0.009470629)
;      ("del" . 0.009057363)
;      ("non" . 0.008437471)
;      ("i" . 0.007266553)
;      ("si" . 0.00719768)
;      ("una" . 0.006302275)
;      ("le" . 0.005854569)
;      ("della" . 0.005785696)
;      ("ha" . 0.00540687)
;      ("con" . 0.004993604)
;      ("da" . 0.004821411)
;      ("al" . 0.004545905)
;      ("ma" . 0.004408145)
;      ("dei" . 0.003753813)
;      ("-" . 00358162)
;      ("gli" . 0.00358162)
;      ("sono" . 0.00358162)
;      ("come" . 0.003065041)
;      ("nel" . 0.002961721)
;      ("anche" . 0.002961721)
;      ("alla" . 0.002445142)
;      ("o" . 0.002272949)
;      ("se" . 0.002272949)
;      ("delle" . 0.001997443)
;      ("lo" . 0.001584177)
;      ("hanno" . 0.001549737)
;      ("ai" . 0.001515304)
;      ("anni" . 0.001515304)
;      ("solo" . 0.001480864)
;      ("due" . 0.001480864)
;      ("questo" . 0.001480864)
;      ("sul" . 0.001446424)
;      ("dopo" . 0.001446424)
;      ("ci" . 0.001411984)
;      ("alle" . 0.001377544)
;      ("loro" . 0.001343104)
;      ("stato" . 0.001343104)
;      ("quando" . 0.001308671)
;      ("dal" . 0.001308671)
;      ("tra" . 0.001308671)
;      ("su" . 0.001274231)
;      ("nella" . 0.001239791)
;      ("sulla" . 0.001239791)
;      ("oggi" . 0.001205351)
;      ("tutti" . 0.001205351)))
    ))


;;; Code:

(defun guess-lang-how-many (regexp)
  "Return number of occurences for REGEXP following point."
  (let ((count 0) opoint)
    (save-excursion
     (while (and (not (eobp))
		 (progn (setq opoint (point))
			(re-search-forward regexp nil t)))
       (if (= opoint (point))
	   (forward-char 1)
	 (setq count (1+ count))))
     count)))


(defun guess-lang-ratio (lang)
  "Compute ratio of occurences of LANG keywords in buffer."
  (let ((numwords (guess-lang-how-many "\\<[a-zA-Z]+\\>")) ; TODO: should it be better to compute this _once_ ?
	(keywords-alist (guess-lang-keyword-list lang)))
    (/ (guess-lang-ratio-1 keywords-alist numwords)
       (float (length keywords-alist)))))


(defun guess-lang-ratio-1 (alist numwords)
  "Recursor for `guess-lang-ratio'.
Argument ALIST is a list of pairs which describe probability of keywords.
Argument NUMWORDS is the number of words in the buffer, passed as an argument to save time."
  (cond
   ((null alist) 0)
   ((let ((occurences (guess-lang-how-many (concat "\\<" (caar alist) "\\>"))))
      (+
       (if (> (/ occurences (float numwords)) (cdar alist))
	   1 0)
       (guess-lang-ratio-1 (cdr alist) numwords))))))
	  

(defun guess-lang-keyword-list (lang)
  "Return keywords list for LANG from `guess-lang-words'.
There may be aliases, see `guess-lang-words' for examples."
  (let ((words (cdr (assoc lang guess-lang-words))))
    (if (stringp words)
	(guess-lang-keyword-list words)
      words)))


(defun guess-lang-buffer (&optional lang)
  "Guess language for current buffer.
Optional argument LANG is a list of language to check.
Defaulted to `guess-languages-to-guess'."
  (save-excursion
    (beginning-of-buffer)
    (guess-lang lang)))


(defun guess-lang-message (&optional lang)
  "Guess language for current buffer, which is a message.
Optional argument LANG is a list of language to check.
Defaulted to `guess-languages-to-guess'."
  (save-excursion
    (message-goto-body)
    (guess-lang lang)))			; TODO: do not check signature


(defun guess-lang-other-buffer (buffer &optional lang)
  "Guess language for another BUFFER.
Optional argument LANG  is a list of language to check.  Defaulted to `guess-languages-to-guess'."
  (save-excursion
    (set-buffer buffer)
    (beginning-of-buffer)
    (guess-lang-1 (or lang guess-languages-to-guess))))


(defun guess-lang (&optional langs)
  "Guess language in current buffer, but only among LANGS."
  (guess-lang-1 (or langs guess-languages-to-guess)))


(defun guess-lang-1 (langs &optional threshold)
  "Compute ratios for every languages in LANGS and return the best one.
THRESHOLD ensure that of no language has better ratio than
THRESHOLD, it won't be returned."
  (cond
   ((null langs) nil)
   ((atom langs) (> (guess-lang-ratio langs) 0))
   ((let ((thres (guess-lang-ratio (car langs))))
      (if (and (> thres (or threshold 0))
	       (not (guess-lang-1 (cdr langs) thres)))
	  (car langs)
	(guess-lang-1 (cdr langs) threshold))))))

(provide 'guess-lang)
(run-hooks 'guess-lang-load-hook)

;;; guess-lang.el ends here