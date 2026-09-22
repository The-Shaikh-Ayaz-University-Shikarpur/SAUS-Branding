%%==========================================================================
%%  saus-certificate.cls
%%  Certificates for THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR
%%  "Revival of Educational Glory of Shikarpur"
%%
%%  Landscape certificates of participation, achievement, appreciation and
%%  so on, in the same colours and typefaces as the slides, posters and
%%  letterhead. Two layouts:
%%    classic  centred, framed, with the crest as a watermark and a gold seal
%%    modern   a maroon band on the left carrying the crest and names
%%  One page per \makecertificate; a CSV file of names gives a whole batch.
%%
%%  Build with LuaLaTeX (recommended) or XeLaTeX; pdfLaTeX works but omits
%%  the Sindhi and Urdu names.
%%
%%  Version 1.0 -- 2026-09-21
%%==========================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{saus-certificate}[2026/09/21 v1.0 Shaikh Ayaz University Shikarpur certificates]

%%--------------------------------------------------------------------------
%% 1. OPTIONS
%%--------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sauscert,prefix=sauscert@}
% path (with trailing slash) to the shared assets folder
\DeclareStringOption[assets/]{assets}
% native = both | sindhi | urdu | none  (names on the certificate)
\DeclareStringOption[both]{native}
% use the brand typefaces
\DeclareBoolOption[true]{fonts}
% style = classic | modern  (default layout; \makecertificate[style=...] overrides)
\DeclareStringOption[classic]{style}
% size = a4 | letter  (always landscape)
\DeclareStringOption[a4]{size}
% sign = 1 | 0  -- print the signatories' signature images
\DeclareStringOption[0]{sign}
% gold seal between the signatures (classic style, one or two signatories)
\DeclareBoolOption[true]{seal}
% modern style: photograph behind the band, or "none" for plain maroon
\DeclareStringOption[default]{bandimage}
\ProcessKeyvalOptions*
\let\@classoptionslist\@empty
\let\@unusedoptionlist\@empty

\RequirePackage{iftex}
\ifPDFTeX\RequirePackage{fix-cm}\fi
\LoadClass[11pt]{article}

%%--------------------------------------------------------------------------
%% 2. BRAND AND PACKAGES
%%--------------------------------------------------------------------------
\edef\saus@tmp{\noexpand\RequirePackage[assets=\sauscert@assets,%
  native=\sauscert@native,fonts=\ifsauscert@fonts true\else false\fi]{saus-brand}}
\saus@tmp

\RequirePackage{geometry}
\ifdefstring{\sauscert@size}{letter}
  {\geometry{letterpaper,landscape,margin=15mm}}
  {\geometry{a4paper,landscape,margin=15mm}}
\RequirePackage{tikz}
\RequirePackage{eso-pic}
\RequirePackage[nolink]{qrcode}
\RequirePackage{csvsimple-l3}
\pagestyle{empty}
\renewcommand{\familydefault}{\sfdefault}

%%--------------------------------------------------------------------------
%% 3. CERTIFICATE FIELDS
%%    Set these in the preamble; \makecertificate[key=value] changes any of
%%    them for one certificate.
%%--------------------------------------------------------------------------
% Date as "21 September 2026"
\newcommand{\saus@today}{\number\day\space\ifcase\month\or January\or February\or
  March\or April\or May\or June\or July\or August\or September\or October\or
  November\or December\fi\space\number\year}

\newcommand{\saus@c@title}{Certificate}
\newcommand{\saus@c@subtitle}{of Participation}
\newcommand{\saus@c@certify}{This is to certify that}
\newcommand{\saus@c@body}{}
\newcommand{\saus@c@date}{\saus@today}
\newcommand{\saus@c@serial}{}
\newcommand{\saus@c@verify}{}
\let\saus@c@style\sauscert@style

% \certificatetitle{Certificate}{of Participation}
\newcommand{\certificatetitle}[2]{%
  \renewcommand{\saus@c@title}{#1}\renewcommand{\saus@c@subtitle}{#2}}
\newcommand{\certificatecertify}[1]{\renewcommand{\saus@c@certify}{#1}}
\newcommand{\certificatebody}[1]{\renewcommand{\saus@c@body}{#1}}
\newcommand{\certificatedate}[1]{\renewcommand{\saus@c@date}{#1}}
% Certificate number; 0 or empty hides it. \thecertificate numbers a batch.
\newcommand{\certificateserial}[1]{\renewcommand{\saus@c@serial}{#1}}
% QR code of an address; \certificatenumber inside it gives this certificate's
% number, e.g. \certificateverify{https://.../verify?no=\certificatenumber}
\newcommand{\certificateverify}[1]{\renewcommand{\saus@c@verify}{#1}}
\newcommand{\certificatenumber}{\saus@serialtext}
\newcommand{\saus@serialtext}{}

\newcounter{certificate}
\renewcommand{\thecertificate}{%
  \ifnum\value{certificate}<100 0\fi\ifnum\value{certificate}<10 0\fi
  \arabic{certificate}}

\pgfkeys{/saus/cert/.cd,
  title/.code={\renewcommand{\saus@c@title}{#1}},
  subtitle/.code={\renewcommand{\saus@c@subtitle}{#1}},
  certify/.code={\renewcommand{\saus@c@certify}{#1}},
  body/.code={\renewcommand{\saus@c@body}{#1}},
  date/.code={\renewcommand{\saus@c@date}{#1}},
  serial/.code={\renewcommand{\saus@c@serial}{#1}},
  verify/.code={\renewcommand{\saus@c@verify}{#1}},
  style/.code={\def\saus@c@style{#1}}}

%%--------------------------------------------------------------------------
%% 4. SIGNATORIES
%%    \signatory[image]{Name}{Designation}, up to three, left to right.
%%    With sign=1 the image is printed above the line; with sign=0, or with
%%    no image, the space is left for a pen signature.
%%--------------------------------------------------------------------------
\newif\ifsaus@sign
\newcommand{\saus@setsign}[1]{%
  \saus@signfalse\edef\saus@tmpa{#1}%
  \ifdefstring{\saus@tmpa}{1}{\saus@signtrue}{}%
  \ifdefstring{\saus@tmpa}{true}{\saus@signtrue}{}%
  \ifdefstring{\saus@tmpa}{yes}{\saus@signtrue}{}}
\saus@setsign{\sauscert@sign}
% \saussign{1|0} switches the images on or off from here on
\newcommand{\saussign}[1]{\saus@setsign{#1}}

\newlength{\saus@signheight}
\setlength{\saus@signheight}{14mm}
\newcommand{\saussignheight}[1]{\setlength{\saus@signheight}{#1}}

\newcount\saus@nsig
\newcommand{\signatory}[3][]{%
  \ifnum\saus@nsig>2
    \ClassError{saus-certificate}{More than three signatories}
      {A certificate has room for three signatures. Use \string\clearsignatories
       \MessageBreak before setting a new list.}%
  \else
    \global\advance\saus@nsig\@ne
    \expandafter\gdef\csname saus@sig@img@\the\saus@nsig\endcsname{#1}%
    \expandafter\gdef\csname saus@sig@name@\the\saus@nsig\endcsname{#2}%
    \expandafter\gdef\csname saus@sig@desig@\the\saus@nsig\endcsname{#3}%
  \fi}
\newcommand{\clearsignatories}{\global\saus@nsig\z@}

% One signature block, #1 = number, #2 = width, #3 = \centering or \raggedright
\newcommand{\saus@sigblock}[3]{%
  \parbox[b]{#2}{#3\saus@nohyphen
    \edef\saus@tmpa{\csname saus@sig@img@#1\endcsname}%
    \rule{0pt}{\saus@signheight}%
    \ifsaus@sign\ifx\saus@tmpa\@empty\else
      \IfFileExists{\saus@tmpa}{%
        \includegraphics[height=\saus@signheight,width=#2,keepaspectratio]{\saus@tmpa}}%
       {\ClassError{saus-certificate}{Signature image `\saus@tmpa' not found}
         {Check the path in \string\signatory[...], or use sign=0.}}%
    \fi\fi\par
    \vskip1mm
    {\color{sausink}\rule{\linewidth}{0.5pt}}\par
    \vskip1.6mm
    {\color{sausink}\fontsize{10.5}{13}\selectfont\bfseries
     \csname saus@sig@name@#1\endcsname\par}%
    {\color{sausslate}\fontsize{9}{11}\selectfont
     \csname saus@sig@desig@#1\endcsname\par}}}

%%--------------------------------------------------------------------------
%% 5. PIECES SHARED BY BOTH LAYOUTS
%%--------------------------------------------------------------------------
\def\saus@zero{0}
% Wide tracking for the word "CERTIFICATE"
\newcommand{\saus@wide}[1]{%
  \ifdefined\addfontfeatures{\addfontfeatures{LetterSpace=22}#1}\else\sausls{#1}\fi}

% Scale #2 down to width #1 if it is wider; never up
\newcommand{\saus@fit}[2]{%
  \sbox\z@{#2}%
  \ifdim\wd\z@>#1\relax\resizebox{#1}{!}{\usebox\z@}\else\usebox\z@\fi}

\newcommand{\saus@namefont}{\rmfamily\itshape\fontsize{36}{42}\selectfont}
\newcommand{\saus@certifyfont}{\rmfamily\itshape\fontsize{14}{17}\selectfont}
\newcommand{\saus@bodyfont}{\fontsize{12.5}{18.5}\selectfont}

% Gold seal: scalloped rosette with the crest in a white disc
\newcommand{\saus@seal}{%
  \begin{tikzpicture}[baseline=(current bounding box.south)]
    \fill[sausgold] plot[domain=0:360,samples=241]
      (\x:{13.6mm+0.5mm*cos(40*\x)}) -- cycle;
    \draw[white,line width=0.6pt] (0,0) circle[radius=12.1mm];
    \fill[white] (0,0) circle[radius=11.4mm];
    \draw[sausmaroon,line width=0.5pt] (0,0) circle[radius=10.8mm];
    \node[inner sep=0pt] at (0,0) {\includegraphics[height=18.6mm]{\sauslogo}};
  \end{tikzpicture}}

% Certificate number and date line
\newcommand{\saus@footline}{%
  {\color{sausslate}\fontsize{8.5}{10}\selectfont
   \ifsaus@hasserial
     {\sauslabelfont\sausls{\MakeUppercase{Certificate No.}}}\enspace
     {\color{sausink}\saus@serialtext}\saus@sep
   \fi
   {\sauslabelfont\sausls{\MakeUppercase{Issued}}}\enspace
   {\color{sausink}\saus@c@date}}}

\newcommand{\saus@qr}{%
  \begingroup\color{sausink}%
  \edef\saus@tmpa{\noexpand\qrcode[height=15mm]{\saus@qrtext}}\saus@tmpa
  \endgroup}

\newif\ifsaus@hasserial
\newif\ifsaus@hasqr
% Resolve the number and QR text for the current certificate
\newcommand{\saus@prepare}{%
  \edef\saus@serialtext{\saus@c@serial}%
  \saus@hasserialtrue
  \ifx\saus@serialtext\@empty\saus@hasserialfalse\fi
  \ifx\saus@serialtext\saus@zero\saus@hasserialfalse\fi
  \ifsaus@hasserial\else\let\saus@serialtext\@empty\fi
  \edef\saus@qrtext{\saus@c@verify}%
  \saus@hasqrtrue
  \ifx\saus@c@verify\@empty\saus@hasqrfalse\fi}

% Layout measurements (dimensions, so both paper sizes work)
\newlength{\saus@rowbottom}  % bottom of the signature row
\newlength{\saus@top}        % top of the text column
\newlength{\saus@avail}      % height available for the text column
\newsavebox{\saus@rowbox}
\newsavebox{\saus@mainbox}
\newsavebox{\saus@pagebox}

% Set #3 in a box of height \saus@avail, spreading the \vskip ... plus 1fil
% gaps; warn if the text is taller than the space.
\newcommand{\saus@column}[3]{% #1 width, #2 name for messages, #3 content
  \setbox\z@\vbox{\hsize=#1\relax#3}%
  \ifdim\dimexpr\ht\z@+\dp\z@\relax>\saus@avail
    \ClassWarningNoLine{saus-certificate}{The certificate for #2\MessageBreak
      is too full by \the\dimexpr\ht\z@+\dp\z@-\saus@avail\relax.
      Shorten the text\MessageBreak or the title}%
    \sbox\saus@mainbox{\box\z@}%
  \else
    \sbox\saus@mainbox{\vbox to\saus@avail{\hsize=#1\relax#3}}%
  \fi}

%%--------------------------------------------------------------------------
%% 6. CLASSIC LAYOUT
%%--------------------------------------------------------------------------
\newcommand{\saus@classic}[1]{%
  % signature row: left, centre and right places
  \dimen@=60mm
  \sbox\saus@rowbox{\hbox to\dimexpr0.52\paperwidth+\dimen@\relax{%
    \ifcase\saus@nsig
      \hfil\ifsauscert@seal\saus@seal\fi\hfil
    \or
      \hbox to\dimen@{\hfil}\hfil
      \hbox to\dimen@{\hfil\ifsauscert@seal\saus@seal\fi\hfil}\hfil
      \saus@sigblock{1}{\dimen@}{\centering}%
    \or
      \saus@sigblock{1}{\dimen@}{\centering}\hfil
      \hbox to\dimen@{\hfil\ifsauscert@seal\saus@seal\fi\hfil}\hfil
      \saus@sigblock{2}{\dimen@}{\centering}%
    \else
      \saus@sigblock{1}{\dimen@}{\centering}\hfil
      \saus@sigblock{2}{\dimen@}{\centering}\hfil
      \saus@sigblock{3}{\dimen@}{\centering}%
    \fi}}%
  \setlength{\saus@rowbottom}{22mm}%
  \setlength{\saus@top}{\dimexpr\paperheight-17mm\relax}%
  \setlength{\saus@avail}{\dimexpr\saus@top-\saus@rowbottom
    -\ht\saus@rowbox-\dp\saus@rowbox-6mm\relax}%
  \saus@column{230mm}{#1}{%
    \centering\saus@nohyphen\parskip\z@
    \includegraphics[height=18mm]{\sauslogo}\par
    \vskip2.5mm
    {\color{sausmaroon}\fontsize{14}{17}\selectfont\sausdisplayfamily\sausdisplayseries
     \sausls{\MakeUppercase{\saus@university}}\par}%
    \vskip0.8mm
    {\color{sausmaroonlight}\fontsize{11.5}{14}\selectfont\sausmottofont\saus@motto\par}%
    \ifx\saus@nativename\@empty\else
      \vskip1mm
      {\color{sausmaroon}\fontsize{12}{19}\selectfont\saus@nativename\par}%
    \fi
    \ifx\saus@department\@empty\else
      \vskip1.2mm
      {\color{sausslate}\fontsize{8.5}{10}\selectfont\sauslabelfont
       \sausls{\MakeUppercase{\saus@department}}\par}%
    \fi
    \vskip5mm plus 1fil
    {\color{sausmaroon}\fontsize{34}{38}\selectfont\sausdisplayfamily\sausdisplayseries
     \saus@wide{\MakeUppercase{\saus@c@title}}\par}%
    \ifx\saus@c@subtitle\@empty\else
      \vskip0.5mm
      {\color{sausmaroonlight}\rmfamily\itshape\fontsize{19}{23}\selectfont
       \saus@c@subtitle\par}%
    \fi
    \vskip2.5mm
    {\color{sausgold}\rule[0.6mm]{18mm}{0.6pt}\hspace{2mm}%
     \raisebox{-0.2mm}{\rotatebox{45}{\rule{1.6mm}{1.6mm}}}%
     \hspace{2mm}\rule[0.6mm]{18mm}{0.6pt}}\par
    \vskip4mm plus 1fil
    {\color{sausslate}\saus@certifyfont\saus@c@certify\par}%
    \vskip2mm
    {\color{sausmaroondark}\saus@namefont\saus@fit{210mm}{#1}\par}%
    \vskip0.5mm
    {\color{sausgold}\rule{120mm}{0.6pt}}\par
    \vskip4mm plus 0.5fil
    \parbox{200mm}{\centering\color{sausink}\saus@bodyfont\saus@c@body\par}\par
    \vskip0pt plus 0.5fil}%
  \begin{tikzpicture}[inner sep=0pt,outer sep=0pt]
    \useasboundingbox (0,0) rectangle (\paperwidth,\paperheight);
    % crest watermark
    \node[opacity=0.05] at (0.5\paperwidth,0.47\paperheight)
      {\includegraphics[height=0.66\paperheight]{\sauslogo}};
    % frame: maroon rule, gold hairline, corner brackets and diamonds
    \draw[sausmaroon,line width=2.2pt]
      (8mm,8mm) rectangle (\paperwidth-8mm,\paperheight-8mm);
    \draw[sausgold,line width=0.7pt]
      (11mm,11mm) rectangle (\paperwidth-11mm,\paperheight-11mm);
    \foreach \sx/\sy in {1/1,-1/1,1/-1,-1/-1}{
      \coordinate (c) at ({0.5\paperwidth-\sx*(0.5\paperwidth-11mm)},
                          {0.5\paperheight-\sy*(0.5\paperheight-11mm)});
      \draw[sausmaroon,line width=1pt]
        ([xshift=\sx*16mm,yshift=\sy*3mm]c) -- ([xshift=\sx*3mm,yshift=\sy*3mm]c)
        -- ([xshift=\sx*3mm,yshift=\sy*16mm]c);
      \fill[sausgold] ([yshift=1.9mm]c) -- ([xshift=1.9mm]c)
        -- ([yshift=-1.9mm]c) -- ([xshift=-1.9mm]c) -- cycle;
    }
    % text column and signature row
    \node[anchor=north] at (0.5\paperwidth,\saus@top) {\usebox\saus@mainbox};
    \node[anchor=south] at (0.5\paperwidth,\saus@rowbottom) {\usebox\saus@rowbox};
    % number, date and QR code
    \node[anchor=base west] at (20mm,17mm) {\saus@footline};
    \ifsaus@hasqr
      \node[anchor=south east] at (\paperwidth-19mm,17.5mm) {\saus@qr};
    \fi
  \end{tikzpicture}}

%%--------------------------------------------------------------------------
%% 7. MODERN LAYOUT
%%--------------------------------------------------------------------------
\newlength{\saus@band}
\setlength{\saus@band}{88mm}
\newcommand{\saus@bandimage}{}
\ifdefstring{\sauscert@bandimage}{default}
  {\renewcommand{\saus@bandimage}{\sausasset{saus-title-bg.jpg}}}
  {\ifdefstring{\sauscert@bandimage}{none}{}
    {\renewcommand{\saus@bandimage}{\sauscert@bandimage}}}

\newcommand{\saus@modern}[1]{%
  \dimen@=\dimexpr\paperwidth-\saus@band-36mm\relax  % text width
  \ifsaus@hasqr\dimen2=\dimexpr\dimen@-26mm\relax\else\dimen2=\dimen@\fi
  \dimen2=\dimexpr(\dimen2-16mm)/3\relax              % signature width
  \sbox\saus@rowbox{\hbox{%
    \ifnum\saus@nsig>0 \saus@sigblock{1}{\dimen2}{\raggedright}\fi
    \ifnum\saus@nsig>1 \hspace{8mm}\saus@sigblock{2}{\dimen2}{\raggedright}\fi
    \ifnum\saus@nsig>2 \hspace{8mm}\saus@sigblock{3}{\dimen2}{\raggedright}\fi}}%
  \setlength{\saus@rowbottom}{22mm}%
  \setlength{\saus@top}{\dimexpr\paperheight-24mm\relax}%
  \setlength{\saus@avail}{\dimexpr\saus@top-\saus@rowbottom
    -\ht\saus@rowbox-\dp\saus@rowbox-8mm\relax}%
  \saus@column{\dimen@}{#1}{%
    \raggedright\saus@nohyphen\parskip\z@
    \ifx\saus@department\@empty\else
      {\color{sausslate}\fontsize{9}{11}\selectfont\sauslabelfont
       \sausls{\MakeUppercase{\saus@department}}\par}%
      \vskip4mm
    \fi
    {\color{sausmaroon}\fontsize{38}{42}\selectfont\sausdisplayfamily\sausdisplayseries
     \saus@wide{\MakeUppercase{\saus@c@title}}\par}%
    \ifx\saus@c@subtitle\@empty\else
      \vskip0.5mm
      {\color{sausmaroonlight}\rmfamily\itshape\fontsize{21}{25}\selectfont
       \saus@c@subtitle\par}%
    \fi
    \vskip4mm
    \fontsize{12}{14}\selectfont\sausrule[70mm]\par
    \vskip8mm plus 1fil
    {\color{sausslate}\saus@certifyfont\saus@c@certify\par}%
    \vskip2mm
    {\color{sausmaroondark}\saus@namefont\saus@fit{\linewidth}{#1}\par}%
    \vskip1mm
    {\color{sausgold}\rule{100mm}{0.6pt}}\par
    \vskip5mm plus 0.5fil
    {\color{sausink}\saus@bodyfont\saus@c@body\par}%
    \vskip0pt plus 0.5fil}%
  \begin{tikzpicture}[inner sep=0pt,outer sep=0pt]
    \useasboundingbox (0,0) rectangle (\paperwidth,\paperheight);
    % band: photograph under deep maroon, gold edge
    \begin{scope}
      \clip (0,0) rectangle (\saus@band,\paperheight);
      \ifx\saus@bandimage\@empty\else
        \node at (0.5\saus@band,0.5\paperheight)
          {\includegraphics[height=\paperheight]{\saus@bandimage}};
      \fi
      \fill[sausmaroondark,opacity=\ifx\saus@bandimage\@empty 1\else 0.87\fi]
        (0,0) rectangle (\saus@band,\paperheight);
    \end{scope}
    \fill[sausgold] (\saus@band,0) rectangle (\saus@band+1.6mm,\paperheight);
    \node[anchor=north] at (0.5\saus@band,\paperheight-20mm) {%
      \parbox{66mm}{\centering\saus@nohyphen\color{white}%
        \includegraphics[height=34mm]{\sauslogowhite}\par
        \vskip6mm
        {\fontsize{11.5}{14.5}\selectfont\sausdisplayfamily\sausdisplayseries
         \sausls{\MakeUppercase{\saus@university}}\par}%
        \vskip2.5mm
        {\color{sausgold}\rule{14mm}{0.8pt}}\par
        \vskip2.5mm
        {\color{white!85!sausmaroon}\fontsize{11}{13.5}\selectfont
         \sausmottofont\saus@motto\par}%
        \ifx\saus@nativestack\@empty\else
          \vskip4mm
          {\fontsize{12.5}{21}\selectfont\saus@nativestack\par}%
        \fi}};
    \node[anchor=south] at (0.5\saus@band,16mm) {%
      \parbox{66mm}{\centering\color{white!80!sausmaroon}\fontsize{8}{11}\selectfont
        \saus@address\par\saus@phone\par
        {\color{white}\bfseries\saus@web}\par}};
    % text column and signature row
    \node[anchor=north west] at (\saus@band+18mm,\saus@top) {\usebox\saus@mainbox};
    \node[anchor=south west] at (\saus@band+18mm,\saus@rowbottom) {\usebox\saus@rowbox};
    % number, date and QR code
    \node[anchor=base west] at (\saus@band+18mm,12.5mm) {\saus@footline};
    \ifsaus@hasqr
      \node[anchor=south east] at (\paperwidth-18mm,\saus@rowbottom) {\saus@qr};
    \fi
  \end{tikzpicture}}

%%--------------------------------------------------------------------------
%% 8. MAKING CERTIFICATES
%%--------------------------------------------------------------------------
% \makecertificate[key=value,...]{Recipient name}
% Keys: title, subtitle, certify, body, date, serial, verify, style.
\newcommand{\makecertificate}[2][]{%
  \begingroup
  \stepcounter{certificate}%
  \pgfkeys{/saus/cert/.cd,#1}%
  \saus@prepare
  \ifdefstring{\saus@c@style}{modern}
    {\global\setbox\saus@pagebox\hbox{\saus@modern{#2}}}
    {\ifdefstring{\saus@c@style}{classic}{}
      {\ClassWarning{saus-certificate}{Unknown style `\saus@c@style',
        using classic}}%
     \global\setbox\saus@pagebox\hbox{\saus@classic{#2}}}%
  \endgroup
  \AddToShipoutPictureBG*{\put(0,0){\usebox\saus@pagebox}}%
  \null\clearpage}

% One certificate per row of a CSV file with the columns "name" and
% "serial". An empty serial uses \certificateserial; 0 hides the number.
% [#1] passes options to \csvreader.
\newcommand{\makecertificatesfromcsv}[2][]{%
  \csvreader[#1]{#2}{name=\saus@csvname,serial=\saus@csvserial}
    {\ifx\saus@csvserial\@empty
       \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
     {\makecertificate{\saus@csvname}}
     {\makecertificate[serial=\saus@csvserial]{\saus@csvname}}}}

\endinput
