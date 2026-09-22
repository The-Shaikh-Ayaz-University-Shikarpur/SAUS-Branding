%%==========================================================================
%%  saus-thesis.cls
%%  Final year project reports and theses for
%%  THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR
%%  "Revival of Educational Glory of Shikarpur"
%%
%%  Built on KOMA-Script's scrbook. Provides the title page, certificate of
%%  approval, declaration, abstract (English, and optionally Urdu or Sindhi),
%%  list of abbreviations, branded chapter openings, running heads, captions,
%%  theorem and code styles, and a biblatex bibliography.
%%
%%  Build with LuaLaTeX (recommended), XeLaTeX or pdfLaTeX, and Biber:
%%    latexmk saus-thesis-demo.tex
%%
%%  Version 1.0 -- 2026-09-22
%%==========================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{saus-thesis}[2026/09/22 v1.0 Shaikh Ayaz University Shikarpur thesis]

%%--------------------------------------------------------------------------
%% 1. OPTIONS
%%--------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=saust,prefix=saust@}
% path (with trailing slash) to the shared assets folder
\DeclareStringOption[assets/]{assets}
% native = both | sindhi | urdu | none  (names on the title page)
\DeclareStringOption[both]{native}
% use the brand typefaces
\DeclareBoolOption[true]{fonts}
% degree = bs | ms | mphil | phd
\DeclareStringOption[bs]{degree}
% type = project | thesis  (default: project for bs, thesis otherwise)
\DeclareStringOption[]{type}
% body = serif (EB Garamond, Garamond-Math) | sans (Fira Sans, Fira Math)
\DeclareStringOption[serif]{body}
% spacing = single | onehalf | double
\DeclareStringOption[onehalf]{spacing}
% bib = ieee | apa | numeric | authoryear | none
\DeclareStringOption[ieee]{bib}
% two-sided printing: chapters open on right-hand pages, mirrored margins
\DeclareBoolOption[false]{twoside}
% print = black links, for the bound copy
\DeclareBoolOption[false]{print}
% status = final | draft  (draft marks every page with "Draft" and the date)
\DeclareStringOption[final]{status}
\ProcessKeyvalOptions*
\let\@classoptionslist\@empty
\let\@unusedoptionlist\@empty

\RequirePackage{iftex}
\ifPDFTeX\RequirePackage{fix-cm}\fi
\edef\saus@tmp{\noexpand\LoadClass[fontsize=12pt,
  twoside=\ifsaust@twoside true\else false\fi,
  open=\ifsaust@twoside right\else any\fi,
  chapterprefix=true,numbers=noenddot,captions=tableheading,
  bibliography=totoc,listof=totoc,headsepline=false,version=last]{scrbook}}
\saus@tmp

%%--------------------------------------------------------------------------
%% 2. BRAND, LANGUAGE AND PACKAGES
%%--------------------------------------------------------------------------
\RequirePackage{amsmath}           % before unicode-math (loaded by the brand)
\RequirePackage{etoolbox}
\newif\ifsaus@serif
\ifdefstring{\saust@body}{sans}{\saus@seriffalse}{\saus@seriftrue}
\edef\saus@tmp{\noexpand\RequirePackage[assets=\saust@assets,native=\saust@native,%
  fonts=\ifsaust@fonts true\else false\fi,math=\ifsaus@serif garamond\else fira\fi]{saus-brand}}
\saus@tmp
\ifsaus@serif
  \renewcommand{\familydefault}{\rmdefault}
\else
  \renewcommand{\familydefault}{\sfdefault}
\fi

\RequirePackage[british]{babel}
\RequirePackage{csquotes}
\RequirePackage{geometry}
\geometry{a4paper,left=38mm,right=25mm,top=30mm,bottom=27mm,
  headheight=26pt,headsep=7.5mm,footskip=12mm}
\RequirePackage{setspace}
\ifdefstring{\saust@spacing}{single}{\singlespacing}{}
\ifdefstring{\saust@spacing}{onehalf}{\onehalfspacing}{}
\ifdefstring{\saust@spacing}{double}{\doublespacing}{}
% tables, figures and listings stay single-spaced
\AtBeginEnvironment{table}{\singlespacing}
\AtBeginEnvironment{figure}{\singlespacing}
\AtBeginEnvironment{lstlisting}{\singlespacing}
% Justified text: a little extra stretch avoids overfull lines next to
% citations and URLs, which cannot be broken
\setlength{\emergencystretch}{2em}
\RequirePackage{ragged2e}
\RequirePackage{enumitem}
\RequirePackage{booktabs}
\RequirePackage{tikz}
\RequirePackage{amsthm}
\RequirePackage{listings}
\RequirePackage{xcolor}

% Degree and document names
\newcommand{\saus@degreefull}{Bachelor of Science}
\ifdefstring{\saust@degree}{ms}{\renewcommand{\saus@degreefull}{Master of Science}}{}
\ifdefstring{\saust@degree}{mphil}{\renewcommand{\saus@degreefull}{Master of Philosophy}}{}
\ifdefstring{\saust@degree}{phd}{\renewcommand{\saus@degreefull}{Doctor of Philosophy}}{}
\ifx\saust@type\@empty
  \ifdefstring{\saust@degree}{bs}{\def\saust@type{project}}{\def\saust@type{thesis}}
\fi
\newif\ifsaus@project
\ifdefstring{\saust@type}{project}{\saus@projecttrue}{\saus@projectfalse}
\newcommand{\saus@doctype}{\ifsaus@project project report\else thesis\fi}
\newcommand{\saus@doclabel}{\ifsaus@project Final Year Project\else
  \ifdefstring{\saust@degree}{phd}{Doctoral Thesis}{Thesis}\fi}

%%--------------------------------------------------------------------------
%% 3. DOCUMENT DETAILS
%%--------------------------------------------------------------------------
\newcommand{\saus@monthyear}{\ifcase\month\or January\or February\or March\or April\or
  May\or June\or July\or August\or September\or October\or November\or
  December\fi\space\number\year}
\newcommand{\saus@discipline}{}
\newcommand{\saus@faculty}{}
\newcommand{\saus@session}{}
\newcommand{\saus@submitted}{\saus@monthyear}
\newcommand{\saus@similarity}{}
\newcommand{\saus@keywords}{}
\newcommand{\saus@supname}{}
\newcommand{\saus@supdesig}{}
\newcommand{\saus@cosupname}{}
\newcommand{\saus@cosupdesig}{}

\newcommand{\discipline}[1]{\renewcommand{\saus@discipline}{#1}}
\newcommand{\faculty}[1]{\renewcommand{\saus@faculty}{#1}}
\newcommand{\session}[1]{\renewcommand{\saus@session}{#1}}
\newcommand{\submissiondate}[1]{\renewcommand{\saus@submitted}{#1}}
\newcommand{\degreename}[1]{\renewcommand{\saus@degreefull}{#1}}
\newcommand{\similarity}[1]{\renewcommand{\saus@similarity}{#1}}
\newcommand{\keywords}[1]{\renewcommand{\saus@keywords}{#1}}
\newcommand{\supervisor}[2]{\renewcommand{\saus@supname}{#1}\renewcommand{\saus@supdesig}{#2}}
\newcommand{\cosupervisor}[2]{\renewcommand{\saus@cosupname}{#1}\renewcommand{\saus@cosupdesig}{#2}}

% \student{Name}{Roll number}, once per group member
\newcount\saus@nstu
\newcommand{\student}[2]{%
  \global\advance\saus@nstu\@ne
  \csgdef{saus@stu@name@\the\saus@nstu}{#1}%
  \csgdef{saus@stu@roll@\the\saus@nstu}{#2}}
% Lists built once at \begin{document}, so they can be used anywhere --
% in table cells (which are groups) and in the PDF metadata (which must expand):
%   \saus@rows          "Name & Roll \\" for each student
%   \saus@studentlist   "A, B and C"
\newcommand{\saus@rows}{}
\newcommand{\saus@studentlist}{}
\newcommand{\saus@row}[1]{\csuse{saus@stu@name@#1} &
  {\color{sausslate}\csuse{saus@stu@roll@#1}}\\}
\AtBeginDocument{%
  \count@\z@
  \loop\ifnum\count@<\saus@nstu
    \advance\count@\@ne
    \eappto\saus@rows{\noexpand\saus@row{\the\count@}}%
    \ifnum\count@>\@ne
      \ifnum\count@=\saus@nstu\appto\saus@studentlist{ and }\else
        \appto\saus@studentlist{, }\fi
    \fi
    \eappto\saus@studentlist{\expandonce{\csname saus@stu@name@\the\count@\endcsname}}%
  \repeat}

% Signature blocks, two to a row
\newcount\saus@sigcount
\newcommand{\saus@sigitem}[2]{%
  \saus@signature{#1}{#2}%
  \global\advance\saus@sigcount\@ne
  \ifodd\saus@sigcount\hfill\else\par\noindent\fi}
\newcommand{\saus@we}{\ifnum\saus@nstu>\@ne We\else I\fi}
\newcommand{\saus@our}{\ifnum\saus@nstu>\@ne our\else my\fi}

% \approvedby{Role}{Name, designation} -- examiners, chairperson, dean ...
\newcount\saus@nappr
\newcommand{\approvedby}[2]{%
  \global\advance\saus@nappr\@ne
  \csgdef{saus@appr@role@\the\saus@nappr}{#1}%
  \csgdef{saus@appr@name@\the\saus@nappr}{#2}}

%%--------------------------------------------------------------------------
%% 4. HEADINGS
%%--------------------------------------------------------------------------
\setkomafont{disposition}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}
\setkomafont{chapter}{\Huge}
\setkomafont{chapterprefix}{\normalsize\sauslabelfont\color{sausgold}}
\setkomafont{section}{\Large}
\setkomafont{subsection}{\large\color{sausink}}
\setkomafont{subsubsection}{\normalsize\color{sausink}}
\setkomafont{paragraph}{\normalsize\color{sausmaroon}}
\setkomafont{descriptionlabel}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}

\RedeclareSectionCommand[beforeskip=0pt,afterskip=1.4\baselineskip,innerskip=0.5\baselineskip,
  afterindent=false,
  tocentryformat=\sausdisplayfamily\sausdisplayseries\color{sausmaroon},
  tocpagenumberformat=\sausdisplayfamily\sausdisplayseries\color{sausmaroon}]{chapter}
\RedeclareSectionCommand[beforeskip=-1.6\baselineskip,afterskip=0.7\baselineskip]{section}
\RedeclareSectionCommand[beforeskip=-1.2\baselineskip,afterskip=0.5\baselineskip]{subsection}

% "CHAPTER 3" in gold capitals, the title, then the signature rule
\renewcommand*{\chapterformat}{%
  \sausls{\MakeUppercase{\chapappifchapterprefix{\nobreakspace}}\thechapter}}
\renewcommand*{\chapterlineswithprefixformat}[3]{%
  \saus@nohyphen\raggedright #2#3\par\nobreak
  \vskip4mm{\normalsize\sausrule[\linewidth]}\par}
\renewcommand*{\chapterlinesformat}[3]{%
  \saus@nohyphen\raggedright #3\par\nobreak
  \vskip4mm{\normalsize\sausrule[\linewidth]}\par}

%%--------------------------------------------------------------------------
%% 5. PAGE STYLE
%%--------------------------------------------------------------------------
\RequirePackage[headsepline=0.4pt,plainheadsepline=false]{scrlayer-scrpage}
\setlength{\footheight}{26pt}      % room for double-spaced text settings
\clearpairofpagestyles
\ifsaust@twoside
  \automark[section]{chapter}
\else
  \automark{chapter}
\fi
\ihead{\headmark}
\ohead{\pagemark}
\cfoot[\pagemark]{}
% running heads stay single-spaced whatever the text spacing
\setkomafont{pageheadfoot}{\linespread{1}\sffamily\footnotesize\color{sausslate}}
\setkomafont{pagenumber}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}
\setkomafont{headsepline}{\color{sausrule}}
\renewcommand*{\chaptermarkformat}{\chapappifchapterprefix{\nobreakspace}\thechapter\enskip
  \textperiodcentered\enskip}
\pagestyle{scrheadings}

\ifdefstring{\saust@status}{draft}{%
  \chead[{\color{sausred}\sffamily\footnotesize Draft\enskip\textperiodcentered\enskip
          \number\day\space\saus@monthyear}]%
        {{\color{sausred}Draft\enskip\textperiodcentered\enskip\number\day\space\saus@monthyear}}}{}

%%--------------------------------------------------------------------------
%% 6. FLOATS, LISTS, THEOREMS, CODE
%%--------------------------------------------------------------------------
\setkomafont{captionlabel}{\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}
\setkomafont{caption}{\small}
\renewcommand*{\captionformat}{\enskip|\enskip}
\setcapindent{0pt}

\setlist{itemsep=0.25\baselineskip,topsep=0.4\baselineskip,leftmargin=*}
\setlist[itemize,1]{label={\textcolor{sausmaroon}{\rule[0.16ex]{0.72ex}{0.72ex}}}}
\setlist[itemize,2]{label={\textcolor{sausblue}{\rule[0.2ex]{0.55ex}{0.55ex}}}}
\setlist[itemize,3]{label={\textcolor{sausgold}{\rule[0.24ex]{0.42ex}{0.42ex}}}}
\setlist[enumerate,1]{label={\textcolor{sausmaroon}{\sausdisplayfamily\sausdisplayseries\arabic*.}}}

\newtheoremstyle{sausplain}{0.8\baselineskip}{0.8\baselineskip}{\itshape}{}%
  {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}{.}{0.5em}{}
\newtheoremstyle{sausdefinition}{0.8\baselineskip}{0.8\baselineskip}{\normalfont}{}%
  {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}}{.}{0.5em}{}
\theoremstyle{sausplain}
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\theoremstyle{sausdefinition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}
\newtheorem{remark}[theorem]{Remark}

\lstdefinestyle{saus}{basicstyle=\ttfamily\small,columns=fullflexible,keepspaces=true,
  keywordstyle=\color{sausmaroon}\bfseries,commentstyle=\color{sausslate},
  stringstyle=\color{sausblue},numbers=left,numberstyle=\scriptsize\color{sausslate},
  numbersep=8pt,xleftmargin=16pt,backgroundcolor=\color{sausmist},frame=l,
  framerule=2pt,rulecolor=\color{sausmaroon},framesep=6pt,breaklines=true,
  aboveskip=0.8\baselineskip,belowskip=0.6\baselineskip,upquote=true}
\lstset{style=saus}
\renewcommand{\lstlistingname}{Listing}
\renewcommand{\lstlistlistingname}{List of Listings}

%%--------------------------------------------------------------------------
%% 7. BIBLIOGRAPHY
%%--------------------------------------------------------------------------
\newcommand{\printreferences}{\PackageWarning{saus-thesis}{bib=none: no bibliography}}
\ifdefstring{\saust@bib}{none}{}{%
  \ifdefstring{\saust@bib}{apa}{\def\saus@bibstyle{apa}}{%
    \ifdefstring{\saust@bib}{numeric}{\def\saus@bibstyle{numeric-comp}}{%
      \ifdefstring{\saust@bib}{authoryear}{\def\saus@bibstyle{authoryear-comp}}{%
        \def\saus@bibstyle{ieee}}}}%
  \edef\saus@tmp{\noexpand\RequirePackage[backend=biber,style=\saus@bibstyle]{biblatex}}%
  \saus@tmp
  % ragged-right references: long titles and URLs do not stretch the lines
  \appto\bibsetup{\RaggedRight}%
  \renewcommand{\printreferences}{\printbibliography[heading=bibintoc,title={References}]}}

%%--------------------------------------------------------------------------
%% 8. LINKS AND PDF DETAILS
%%--------------------------------------------------------------------------
\ifsaust@print
  \RequirePackage[hidelinks,bookmarksnumbered]{hyperref}
\else
  \RequirePackage[colorlinks,linkcolor=sausmaroon,citecolor=sausblue,urlcolor=sausblue,
    bookmarksnumbered]{hyperref}
\fi
\AtBeginDocument{\hypersetup{pdftitle={\@title},pdfauthor={\saus@studentlist},
  pdfsubject={\saus@degreefull\ifx\saus@discipline\@empty\else\space in \saus@discipline\fi,
    \saus@university},pdfkeywords={\saus@keywords}}}

%%--------------------------------------------------------------------------
%% 9. FRONT MATTER
%%--------------------------------------------------------------------------
\newcommand{\saus@label}[1]{{\sauslabelfont\small\color{sausgold}\sausls{\MakeUppercase{#1}}}}

% Title page
\newcommand{\maketitlepage}{%
  \begin{titlepage}
  \singlespacing\centering\saus@nohyphen
  \includegraphics[height=32mm]{\sauslogo}\par
  \vspace{5mm}
  {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}\large
   \sausls{\MakeUppercase{\saus@university}}\par}
  \vspace{1.5mm}
  {\color{sausmaroonlight}\sausmottofont\saus@motto\par}
  \ifx\saus@nativestack\@empty\else
    \vspace{2mm}{\color{sausmaroon}\large\saus@nativestack\par}\fi
  \vfill
  \saus@label{\saus@doclabel}\par
  \vspace{4mm}
  {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}\fontsize{24}{29}\selectfont
   \@title\par}
  \ifx\@subtitle\@empty\else
    \vspace{3mm}{\sauslightfont\color{sausslate}\Large\@subtitle\par}\fi
  \vspace{6mm}
  {\sausrule[5cm]}\par
  \vfill
  \begin{minipage}{0.8\linewidth}\centering
    A \saus@doctype\ submitted in partial fulfilment of the requirements for
    the degree of\par\vspace{1.5mm}
    {\bfseries\saus@degreefull\ifx\saus@discipline\@empty\else\ in \saus@discipline\fi}\par
  \end{minipage}\par
  \vfill
  \saus@label{Submitted by}\par\vspace{2mm}
  \begin{tabular}{@{}l@{\hspace{2.5em}}l@{}}
    \saus@rows
  \end{tabular}\par
  \vspace{6mm}
  \saus@label{Supervised by}\par\vspace{2mm}
  \saus@supname\par{\small\color{sausslate}\saus@supdesig\par}
  \ifx\saus@cosupname\@empty\else
    \vspace{2mm}\saus@cosupname\par{\small\color{sausslate}\saus@cosupdesig\par}\fi
  \vfill
  {\color{sausrule}\rule{\linewidth}{0.4pt}}\par\vspace{3mm}
  {\small
   \ifx\saus@department\@empty\else\saus@department\par\fi
   \ifx\saus@faculty\@empty\else\saus@faculty\par\fi
   \saus@university\par
   {\color{sausslate}\ifx\saus@session\@empty\else Session \saus@session
     \enskip\textperiodcentered\enskip\fi\saus@submitted}\par}
  \end{titlepage}}

% Full-page cover in the university's colours, for the PDF copy
\newcommand{\makecover}{%
  \begin{titlepage}
  \thispagestyle{empty}
  \begin{tikzpicture}[remember picture,overlay]
    \fill[sausmaroondark] (current page.south west) rectangle (current page.north east);
    \node[opacity=0.07,inner sep=0pt] at ([xshift=0.22\paperwidth]current page.center)
      {\includegraphics[height=1.05\paperheight]{\sauslogowhite}};
    \fill[sausgold] ([yshift=-0.34\paperheight]current page.north west) rectangle
      ([yshift=-0.34\paperheight-1.2mm]current page.north east);
    \node[anchor=north west,inner sep=0pt] (crest) at ([shift={(25mm,-25mm)}]current page.north west)
      {\includegraphics[height=26mm]{\sauslogowhite}};
    \node[anchor=west,inner sep=0pt,align=left,text=white] at ([xshift=7mm]crest.east)
      {{\sauslabelfont\sausls{\MakeUppercase{\saus@university}}}\\[2mm]
       {\color{sausgold}\sausmottofont\saus@motto}%
       \ifx\saus@nativename\@empty\else\\[2mm]{\small\saus@nativename}\fi};
    \node[anchor=north west,inner sep=0pt,align=left,text width=0.72\paperwidth,text=white]
      at ([shift={(25mm,-0.34\paperheight-16mm)}]current page.north west)
      {{\color{sausgold}\sauslabelfont\small\sausls{\MakeUppercase{\saus@doclabel}}}\\[5mm]
       {\saus@nohyphen\sausdisplayfamily\sausdisplayseries\fontsize{30}{36}\selectfont\@title}%
       \ifx\@subtitle\@empty\else\\[4mm]{\sauslightfont\Large\color{sausmist}\@subtitle}\fi
       \\[8mm]{\color{sausgold}\rule{4cm}{1.2pt}}\\[8mm]
       {\large\saus@studentlist}\\[2mm]
       {\color{sausmist}\saus@degreefull\ifx\saus@discipline\@empty\else\ in \saus@discipline\fi}};
    \node[anchor=south west,inner sep=0pt,align=left,text=sausmist]
      at ([shift={(25mm,22mm)}]current page.south west)
      {\small\ifx\saus@department\@empty\else\saus@department\enskip\textperiodcentered\enskip\fi
       \saus@submitted\\[1mm]\footnotesize\saus@web\saus@sep\saus@address\saus@sep\saus@phone};
  \end{tikzpicture}
  \end{titlepage}}

% A signature block: #1 role, #2 name and designation
\newcommand{\saus@signature}[2]{%
  \begin{minipage}[t]{0.45\linewidth}\raggedright
    \vspace*{16mm}{\color{sausink}\rule{\linewidth}{0.4pt}}\par\vspace{1.2mm}
    {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}#1}\par
    \ifx\relax#2\relax\else{\small #2}\par\fi
  \end{minipage}}

% Certificate of approval: supervisor, co-supervisor, then \approvedby entries
\newcommand{\makeapproval}{%
  \addchap{Certificate of Approval}
  {\singlespacing
  This is to certify that the \saus@doctype\ entitled
  \enquote{\textit{\@title}}, submitted by \saus@studentlist, has been examined and
  approved as fulfilling the requirements for the degree of
  \saus@degreefull\ifx\saus@discipline\@empty\else\ in \saus@discipline\fi.\par
  \vspace{4mm}\noindent
  \global\saus@sigcount\z@
  \saus@sigitem{Supervisor}{\saus@supname\ifx\saus@supdesig\@empty\else\\\saus@supdesig\fi}%
  \ifx\saus@cosupname\@empty\else
    \saus@sigitem{Co-supervisor}{\saus@cosupname\ifx\saus@cosupdesig\@empty\else
      \\\saus@cosupdesig\fi}%
  \fi
  \@tempcnta\z@
  \loop\ifnum\@tempcnta<\saus@nappr
    \advance\@tempcnta\@ne
    \saus@sigitem{\csuse{saus@appr@role@\the\@tempcnta}}%
      {\csuse{saus@appr@name@\the\@tempcnta}}%
  \repeat
  \par}}

% Declaration by the student(s)
\newcommand{\makedeclaration}{%
  \addchap{Declaration}
  {\singlespacing
  \saus@we\ hereby declare that this \saus@doctype, entitled
  \enquote{\textit{\@title}}, is \saus@our\ own work, carried out under the
  supervision of \saus@supname. It has not been submitted, in whole or in part,
  for any other degree or qualification at this or any other institution. Work
  by others that is used in it has been acknowledged and cited in the text and
  listed in the references.
  \ifx\saus@similarity\@empty\else\par\medskip
    The similarity index of this \saus@doctype, as reported by the university's
    plagiarism detection service, is \saus@similarity.\fi
  \par\vspace{4mm}\noindent
  \global\saus@sigcount\z@
  \@tempcnta\z@
  \loop\ifnum\@tempcnta<\saus@nstu
    \advance\@tempcnta\@ne
    \saus@sigitem{\csuse{saus@stu@name@\the\@tempcnta}}%
      {\csuse{saus@stu@roll@\the\@tempcnta}}%
  \repeat
  \par}}

% Dedication, on a page of its own (replaces KOMA's title-page \dedication)
\renewcommand*{\dedication}[1]{%
  \cleardoublepage\thispagestyle{empty}%
  \vspace*{0.3\textheight}%
  \begin{center}\sausmottofont\large\color{sausmaroondark}#1\end{center}%
  \cleardoublepage}

\newenvironment{acknowledgements}{\addchap{Acknowledgements}}{}

% Abstract, with the keywords after it when \keywords is set
\newenvironment{abstract}{\addchap{Abstract}}{%
  \ifx\saus@keywords\@empty\else\par\medskip\noindent
    {\sausdisplayfamily\sausdisplayseries\color{sausmaroon}Keywords:}\enskip\saus@keywords\par\fi}

% Abstract in Urdu or Sindhi, right to left (LuaLaTeX)
\newcommand{\saus@rtlabstract}[3]{% #1 heading, #2 font switch, #3 body
  \addchap{#1}
  \ifLuaTeX
    {\pardir TRT\textdir TRT\setstretch{1.9}#2#3\par}%
  \else
    \ClassWarning{saus-thesis}{The #1 needs LuaLaTeX; it is left out}%
    \textit{(The #1 is set with LuaLaTeX.)}\par
  \fi}
\ifdefined\saus@urdufont
  \NewDocumentEnvironment{urduabstract}{+b}
    {\saus@rtlabstract{Abstract in Urdu}{\saus@urdufont}{#1}}{}
  \NewDocumentEnvironment{sindhiabstract}{+b}
    {\saus@rtlabstract{Abstract in Sindhi}{\saus@sindhifont}{#1}}{}
\else
  \NewDocumentEnvironment{urduabstract}{+b}
    {\saus@rtlabstract{Abstract in Urdu}{}{}}{}
  \NewDocumentEnvironment{sindhiabstract}{+b}
    {\saus@rtlabstract{Abstract in Sindhi}{}{}}{}
\fi

% List of abbreviations: \abbr{HEC}{Higher Education Commission}
\newenvironment{abbreviations}
  {\addchap{List of Abbreviations}%
   \singlespacing
   \begin{description}[style=sameline,leftmargin=30mm,labelwidth=26mm,itemsep=0.3\baselineskip]}
  {\end{description}}
\newcommand{\abbr}[2]{\item[#1]#2}

\endinput
