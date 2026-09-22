%%==========================================================================
%%  saus-letter.cls
%%  Official letterhead for THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR
%%  "Revival of Educational Glory of Shikarpur"
%%
%%  Built on KOMA-Script's scrlttr2 (address field, reference line, subject,
%%  signature, enclosures, continuation pages) and the shared brand layer
%%  saus-brand.sty, so letters match the slides and posters.
%%
%%  Version 1.0 -- 2026-09-21
%%  Build with LuaLaTeX (recommended) or XeLaTeX. pdfLaTeX also works,
%%  without the Sindhi/Urdu names.
%%==========================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{saus-letter}[2026/09/21 v1.0 Shaikh Ayaz University Shikarpur letterhead]

%%--------------------------------------------------------------------------
%% 1. OPTIONS
%%--------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sausletter,prefix=sausletter@}
% path (with trailing slash) to the shared assets folder
\DeclareStringOption[assets/]{assets}
% native = both | sindhi | urdu | none  (names in the header)
\DeclareStringOption[both]{native}
% use the brand typefaces
\DeclareBoolOption[true]{fonts}
% greyscale version for black-and-white printers
\DeclareBoolOption[false]{mono}
% DIN fold and punch marks in the left margin
\DeclareBoolOption[false]{foldmarks}
% sign = 1 | 0  -- place the signature image above the signature block
\DeclareStringOption[0]{sign}
% closing = left | right  -- side of the page for closing, signature and name
\DeclareStringOption[left]{closing}
\ProcessKeyvalOptions*
\let\@classoptionslist\@empty
\let\@unusedoptionlist\@empty

% pdfLaTeX only: scalable Computer Modern at the header's non-standard sizes
\RequirePackage{iftex}
\ifPDFTeX\RequirePackage{fix-cm}\fi

\edef\saus@tmp{\noexpand\LoadClass[fontsize=11pt,parskip=half,
  firsthead=true,firstfoot=true,addrfield=true,backaddress=false,
  refline=wide,refline=dateright,subject=titled,subject=left,
  foldmarks=\ifsausletter@foldmarks true\else false\fi,
  enlargefirstpage=true,version=last]{scrlttr2}}
\saus@tmp

%%--------------------------------------------------------------------------
%% 2. BRAND, LANGUAGE AND PACKAGES
%%--------------------------------------------------------------------------
\edef\saus@tmp{\noexpand\RequirePackage[assets=\sausletter@assets,%
  native=\sausletter@native,fonts=\ifsausletter@fonts true\else false\fi]{saus-brand}}
\saus@tmp

% British English: "21 September 2026", British captions and hyphenation
\RequirePackage[british]{babel}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage[headsepline=0.4pt,plainheadsepline]{scrlayer-scrpage}
\RequirePackage{ragged2e}
\RequirePackage{enumitem}

% The brand's square bullets, as on the slides and posters
\setlist{itemsep=0.3\baselineskip,parsep=0pt,topsep=0pt,labelsep=0.6em,leftmargin=*}
\setlist[itemize,1]{label={\textcolor{sausmaroon}{\rule[0.16ex]{0.72ex}{0.72ex}}}}
\setlist[itemize,2]{label={\textcolor{sausblue}{\rule[0.2ex]{0.55ex}{0.55ex}}}}
\setlist[itemize,3]{label={\textcolor{sausgold}{\rule[0.24ex]{0.42ex}{0.42ex}}}}
\setlist[enumerate,1]{label={\textcolor{sausmaroon}{\bfseries\arabic*.}}}

\renewcommand{\familydefault}{\sfdefault}
% Justified letters: a little extra stretch avoids overfull lines
\setlength{\emergencystretch}{1.5em}

% Text area for continuation pages; the first page is positioned by the
% KOMA pseudo-lengths below. All content stays at least 12 mm from the
% paper edge, inside the printable area of office printers.
\RequirePackage{geometry}
\geometry{a4paper,left=22mm,right=22mm,top=34mm,bottom=28mm,
  headheight=12mm,headsep=8mm,footskip=12mm}

\newcommand{\saus@crest}{\sauslogo}
\ifsausletter@mono
  \renewcommand{\saus@crest}{\sausasset{saus-logo-gray.png}}
  \AtBeginDocument{\selectcolormodel{gray}}
\fi

%%--------------------------------------------------------------------------
%% 3. EXTRA IDENTITY FIELD
%%--------------------------------------------------------------------------
% Office e-mail, shown in the footer when set
\newcommand{\saus@email}{}
\newcommand{\sausemail}[1]{\renewcommand{\saus@email}{#1}}

%%--------------------------------------------------------------------------
%% 4. FIRST-PAGE LAYOUT (KOMA pseudo-lengths)
%%--------------------------------------------------------------------------
\setplength{firstheadvpos}{12mm}
\setplength{firstheadhpos}{22mm}
\setplength{firstheadwidth}{\dimexpr\paperwidth-44mm\relax}
% Reference line ("Ref. No. ... Dated ...") on one line under the letterhead,
% then the addressee, then the body. \saus@reflinepos places the reference
% line; refvpos is where the body starts (below the address field).
\newlength{\saus@reflinepos}
\setlength{\saus@reflinepos}{44mm}
\setplength{toaddrvpos}{54mm}
\setplength{toaddrhpos}{22mm}
\setplength{toaddrwidth}{95mm}
\setplength{toaddrheight}{25mm}    % room for a five-line address
\setplength{toaddrindent}{0pt}
\setplength{backaddrheight}{0pt}   % no return-address line above the addressee
\setplength{refvpos}{80mm}
\setplength{refhpos}{22mm}
\setplength{refwidth}{\dimexpr\paperwidth-44mm\relax}
\setplength{firstfootvpos}{\dimexpr\paperheight-22mm\relax}
\setplength{firstfoothpos}{22mm}
\setplength{firstfootwidth}{\dimexpr\paperwidth-44mm\relax}
\setplength{sigbeforevskip}{16mm}

%%--------------------------------------------------------------------------
%% 5. LETTERHEAD (first page)
%%--------------------------------------------------------------------------
\newcommand{\saus@firsthead}{%
  \parbox[b]{\useplength{firstheadwidth}}{%
    \normalsize\saus@nohyphen
    \begin{minipage}[c]{19mm}
      \includegraphics[width=\linewidth]{\saus@crest}%
    \end{minipage}%
    \hspace{5mm}%
    \begin{minipage}[c]{\dimexpr\useplength{firstheadwidth}-24mm-50mm\relax}\RaggedRight
      {\color{sausmaroon}\fontsize{11.5}{14}\selectfont\sausdisplayfamily\sausdisplayseries
       \sausls{\MakeUppercase{\saus@university}}\par}%
      \vskip1.2mm
      {\color{sausmaroonlight}\fontsize{11.5}{13}\selectfont\sausmottofont\saus@motto\par}%
      \ifx\saus@department\@empty\else
        \vskip2.2mm
        {\color{sausslate}\fontsize{8.5}{10}\selectfont\sauslabelfont
         \sausls{\MakeUppercase{\saus@department}}\par}%
      \fi
    \end{minipage}%
    \hfill
    \begin{minipage}[c]{49mm}\RaggedLeft
      {\color{sausmaroon}\fontsize{12}{20}\selectfont\saus@nativestack\par}%
    \end{minipage}\par
    \vskip4.5mm
    \sausrule[\linewidth]\par}}

\newcommand{\saus@firstfoot}{%
  \parbox[t]{\useplength{firstfootwidth}}{%
    {\color{sausrule}\rule{\linewidth}{0.4pt}}\par\vskip1.8mm
    \centering\fontsize{8.5}{11}\selectfont\color{sausslate}%
    \saus@address\saus@sep\saus@phone\saus@sep
    {\color{sausmaroon}\saus@web}%
    \ifx\saus@email\@empty\else\saus@sep\href{mailto:\saus@email}{\saus@email}\fi\par}}

\setkomavar{firsthead}{\saus@firsthead}
\setkomavar{firstfoot}{\saus@firstfoot}

%%--------------------------------------------------------------------------
%% 6. CONTINUATION PAGES
%%--------------------------------------------------------------------------
\clearpairofpagestyles
\ihead{%
  \raisebox{-0.32\height}{\includegraphics[height=8mm]{\saus@crest}}\hspace{3mm}%
  {\color{sausmaroon}\sauslabelfont\footnotesize\sausls{\MakeUppercase{\saus@university}}}}
\ohead{%
  {\color{sausslate}\footnotesize
   \saus@ifref{myref}{\usekomavar{myref}\saus@sep}{}%
   Page \thepage\ of \letterlastpage}}
\setkomafont{pageheadfoot}{\normalfont\normalcolor}
\setkomafont{headsepline}{\color{sausrule}}
\pagestyle{scrheadings}

%%--------------------------------------------------------------------------
%% 7. LETTER ELEMENTS
%%--------------------------------------------------------------------------
% Reference line: "Ref. No." and "Dated", the usual form for official letters
\setkomavar*{myref}{Ref.\ No.}
\setkomavar*{date}{Dated}
\setkomavar*{yourref}{Your ref.}
\setkomavar*{yourmail}{Your letter of}

% Date as "21 September 2026" (babel's British style would give "21st")
\newcommand{\saus@today}{\number\day\space\ifcase\month\or January\or February\or
  March\or April\or May\or June\or July\or August\or September\or October\or
  November\or December\fi\space\number\year}
\setkomavar{date}{\saus@today}

% Labels used in official correspondence
\renewcaptionname{british}{\enclname}{Enclosure}
\renewcaptionname{british}{\ccname}{Copy to}

% Notifications, office orders and circulars: no addressee, the reference
% line moves up under the letterhead and #1 is set as a centred title.
% Use inside the letter environment, before \opening.
\newcommand{\sausnotice}[1]{%
  \KOMAoptions{addrfield=false}%
  \setplength{refvpos}{52mm}%
  \setkomavar{title}{#1}}
\setkomafont{lettertitle}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}\Large}

% Signature block aligned with the closing, not centred
\renewcommand*{\raggedsignature}{\raggedright}

\setkomafont{refname}{\color{sausmaroon}\sauslabelfont\small}
\setkomafont{refvalue}{\normalsize}

% One-line reference: "Ref. No. <myref>  [Your ref. <yourref>]  ...  Dated <date>".
% Replaces scrlttr2's two-row reference line. The line is drawn in a
% zero-height box reaching up to \saus@reflinepos, so the body still starts
% at refvpos, below the address field.
\newcommand{\saus@reffield}[1]{%
  {\usekomafont{refname}\usekomavar*{#1}}\enspace{\usekomafont{refvalue}\usekomavar{#1}}}
% A reference set to 0 counts as not given: \setkomavar{myref}{0} hides "Ref. No."
\def\saus@zero{0}
\newcommand{\saus@ifref}[3]{%
  \Ifkomavarempty{#1}{#3}{%
    \expandafter\ifx\csname scr@#1@var\endcsname\saus@zero
      \expandafter\@secondoftwo\else\expandafter\@firstoftwo\fi{#2}{#3}}}
\newcommand{\saus@refline}{%
  \saus@ifref{myref}{\saus@reffield{myref}}{}%
  \saus@ifref{yourref}{\hspace{2.5em}\saus@reffield{yourref}}{}%
  \hfill
  \Ifkomavarempty{date}{}{\saus@reffield{date}}}
\renewcommand*{\@datefield}{{%
  \setparsizes{\z@}{\z@}{\z@ plus 1fil}\par@updaterelative
  \move@topt\vskip\useplength{refvpos}%
  \nointerlineskip
  \vbox to\z@{%
    \vskip\dimexpr\saus@reflinepos-\useplength{refvpos}\relax
    \hbox to\hsize{\move@topl\hskip\useplength{refhpos}%
      \rlap{\hbox to\useplength{refwidth}{\normalsize\strut\saus@refline}}\hss}%
    \vss}%
  \vskip\useplength{refaftervskip}}}
\setkomafont{lettersubject}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}
\setkomafont{toname}{\bfseries}
\setkomafont{foldmark}{\color{sausrule}}

%%--------------------------------------------------------------------------
%% 8. SIGNATURE IMAGE
%%    \documentclass[sign=1]{saus-letter}   sign every letter in the file
%%    \saussign{0} / \saussign{1}           switch per letter (before \closing)
%%    \saussignimage[height]{file}          image file, default
%%                                          signature-trans.png, 17 mm high
%%    The image is looked up relative to the .tex file, NOT in the shared
%%    assets folder, so a signature is never distributed with the templates.
%%--------------------------------------------------------------------------
\newif\ifsaus@sign
\newcommand{\saussign}[1]{%
  \edef\saus@tmpa{#1}\saus@signfalse
  \ifdefstring{\saus@tmpa}{1}{\saus@signtrue}{}%
  \ifdefstring{\saus@tmpa}{true}{\saus@signtrue}{}%
  \ifdefstring{\saus@tmpa}{yes}{\saus@signtrue}{}}
\saussign{\sausletter@sign}

\newcommand{\saus@signfile}{signature-trans.png}
\newlength{\saus@signheight}
\setlength{\saus@signheight}{17mm}
\newcommand{\saussignimage}[2][17mm]{%
  \setlength{\saus@signheight}{#1}\renewcommand{\saus@signfile}{#2}}

% Zero-size image raised into the signing space KOMA leaves above the
% signature block (sigbeforevskip), overlapping the name slightly as a
% handwritten signature would. It changes no spacing, signed or not.
\newcommand{\saus@signmark}{%
  \makebox[0pt][l]{\raisebox{0.55\baselineskip}[0pt][0pt]{%
    \includegraphics[height=\saus@signheight]{\saus@signfile}}}}

%%--------------------------------------------------------------------------
%% 9. CLOSING POSITION
%%    \documentclass[closing=right]{saus-letter}   whole file
%%    \sausclosing{right} / \sausclosing{left}     one letter (before \closing)
%%    Right: the closing, signature and name form one block whose right edge
%%    sits on the right margin; its lines stay left-aligned with each other.
%%    Enclosure and copy lists stay on the left.
%%--------------------------------------------------------------------------
\newif\ifsaus@closeright
\newcommand{\sausclosing}[1]{%
  \edef\saus@tmpa{#1}\saus@closerightfalse
  \ifdefstring{\saus@tmpa}{right}{\saus@closerighttrue}{}}
\sausclosing{\sausletter@closing}

% Push the block right with \leftskip so it ends at the right margin. KOMA
% sizes the block to the wider of the closing words and the signature lines;
% we measure the same and indent by the difference. KOMA's parskip=half
% gives every paragraph's last line \parfillskip = 1em plus 1fil, and since
% this line runs exactly to the margin that 1em would overrun it -- so the
% natural part is zeroed here. The group around \closing keeps both
% settings away from the enclosure and copy lists.
\newcommand{\saus@closingindent}[1]{%
  \ifsaus@closeright
    \par
    \sbox\z@{#1}%
    \sbox\tw@{\begin{tabular}{@{}l@{}}\usekomavar{signature}\end{tabular}}%
    \dimen@=\wd\z@
    \ifdim\wd\tw@>\dimen@ \dimen@=\wd\tw@\fi
    % A signature image wider than the text would overhang the margin
    \ifsaus@sign\IfFileExists{\saus@signfile}{%
      \sbox\tw@{\includegraphics[height=\saus@signheight]{\saus@signfile}}%
      \ifdim\wd\tw@>\dimen@ \dimen@=\wd\tw@\fi}{}\fi
    \ifdim\dimen@>\linewidth \dimen@=\linewidth\fi
    \leftskip=\dimexpr\linewidth-\dimen@\relax
    \parfillskip=\z@ \@plus 1fil\relax
  \fi}

% Wrap \closing: inside a group, place the closing block (section 9) and
% prefix the signature variable with the image (section 8). Everything is
% local, so nothing accumulates across several letters in a file.
\let\saus@komaclosing\closing
\renewcommand*{\closing}[1]{%
  \begingroup
    \saus@closingindent{#1}%
    \ifsaus@sign
      \IfFileExists{\saus@signfile}{%
        \let\saus@origsig\scr@signature@var
        \def\scr@signature@var{\saus@signmark\saus@origsig}%
      }{%
        \ClassError{saus-letter}{Signature image `\saus@signfile' not found}%
          {Put the image next to the .tex file, give its path with
           \string\saussignimage{path}, or build unsigned with sign=0.}%
      }%
    \fi
    \saus@komaclosing{#1}%
  \endgroup}

\endinput
