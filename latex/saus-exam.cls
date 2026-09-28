%%==========================================================================
%%  saus-exam.cls
%%  Examination papers for THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR
%%  "Revival of Educational Glory of Shikarpur"
%%
%%  Mid-term, final-term, sessional and make-up papers on one layout: the
%%  printed heading with the course and paper details, a roll number strip,
%%  instructions, sections, numbered questions with the marks in the margin,
%%  multiple-choice items, ruled answer space, model answers, and a
%%  marks/CLO distribution table collected from the questions themselves.
%%
%%  solutions=1 turns the same file into the answer key; answers=1 sets it
%%  as a paper written on the question paper itself.
%%
%%  Build with LuaLaTeX (recommended), XeLaTeX or pdfLaTeX:
%%    latexmk saus-exam-demo.tex
%%  Two runs settle the marks table and "Page 1 of n"; latexmk does that.
%%
%%  Version 1.0 -- 2026-09-28
%%==========================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{saus-exam}[2026/09/28 v1.0 Shaikh Ayaz University Shikarpur examination paper]

%%--------------------------------------------------------------------------
%% 1. OPTIONS
%%--------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sausexam,prefix=sausexam@}
% path (with trailing slash) to the shared assets folder
\DeclareStringOption[assets/]{assets}
% native = both | sindhi | urdu | none  (names in the heading)
\DeclareStringOption[both]{native}
% use the brand typefaces
\DeclareBoolOption[true]{fonts}
% type = mid | final | sessional | quiz | makeup | supplementary | practical
\DeclareStringOption[mid]{type}
% body type size
\DeclareStringOption[12pt]{fontsize}
% solutions = 1: print the model answers and mark the correct choices
\DeclareStringOption[0]{solutions}
% clo = 1: show each question's CLO and cognitive level
\DeclareStringOption[1]{clo}
% student = 1: roll number strip under the heading
\DeclareStringOption[1]{student}
% rollhead = 1: "Roll No." line in the running head of later pages
\DeclareStringOption[1]{rollhead}
\ProcessKeyvalOptions*
\let\@classoptionslist\@empty
\let\@unusedoptionlist\@empty

\RequirePackage{etoolbox}
\RequirePackage{iftex}
\ifPDFTeX\RequirePackage{fix-cm}\fi

% Switches take 1/0 (also true/yes), as everywhere else in the suite
\newcommand{\saus@setsw}[2]{%
  \edef\saus@tmpa{#2}\csname #1false\endcsname
  \ifdefstring{\saus@tmpa}{1}{\csname #1true\endcsname}{}%
  \ifdefstring{\saus@tmpa}{true}{\csname #1true\endcsname}{}%
  \ifdefstring{\saus@tmpa}{yes}{\csname #1true\endcsname}{}}
\newif\ifsaus@solutions \saus@setsw{saus@solutions}{\sausexam@solutions}
\newif\ifsaus@clo       \saus@setsw{saus@clo}{\sausexam@clo}
\newif\ifsaus@student   \saus@setsw{saus@student}{\sausexam@student}
\newif\ifsaus@rollhead  \saus@setsw{saus@rollhead}{\sausexam@rollhead}

\edef\saus@tmp{\noexpand\LoadClass[\sausexam@fontsize,a4paper]{article}}
\saus@tmp

%%--------------------------------------------------------------------------
%% 2. BRAND, PAGE AND PACKAGES
%%--------------------------------------------------------------------------
\PassOptionsToPackage{table}{xcolor}     % \rowcolor in the marks table
\edef\saus@tmp{\noexpand\RequirePackage[assets=\sausexam@assets,%
  native=\sausexam@native,fonts=\ifsausexam@fonts true\else false\fi]{saus-brand}}
\saus@tmp
\renewcommand{\familydefault}{\sfdefault}

% The right margin carries the marks, so it is wider than the left.
\RequirePackage[a4paper,left=20mm,right=30mm,top=16mm,bottom=18mm,
  headheight=26pt,headsep=5mm,footskip=11mm,
  marginparwidth=18mm,marginparsep=5mm]{geometry}

\RequirePackage[british]{babel}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{lastpage}
\RequirePackage{fancyhdr}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage{enumitem}
\RequirePackage{ragged2e}
\RequirePackage{environ}
\RequirePackage{xkeyval}
\RequirePackage{amsmath}
% \fpeval is in the kernel of current LaTeX; xfp provides it in older ones
\ifdefined\fpeval\else\RequirePackage{xfp}\fi

\setlength{\parindent}{0pt}
\setlength{\parskip}{0.45\baselineskip plus 2pt minus 1pt}
\setlength{\emergencystretch}{1.5em}
\arrayrulecolor{sausrule}
\setlength{\arrayrulewidth}{0.4pt}
\clubpenalty=8000
\widowpenalty=8000

% The brand's square bullets
\setlist{itemsep=0.3\baselineskip,parsep=0pt,topsep=0.3\baselineskip,
  labelsep=0.6em,leftmargin=*}
\setlist[itemize,1]{label={\textcolor{sausmaroon}{\rule[0.16ex]{0.72ex}{0.72ex}}}}
\setlist[itemize,2]{label={\textcolor{sausblue}{\rule[0.2ex]{0.55ex}{0.55ex}}}}
\setlist[enumerate,1]{label={\textcolor{sausmaroon}{\bfseries\arabic*.}}}

%%--------------------------------------------------------------------------
%% 3. THE PAPER'S DETAILS
%%--------------------------------------------------------------------------
\newcommand{\saus@coursecode}{}
\newcommand{\saus@coursetitle}{}
\newcommand{\saus@programme}{}
\newcommand{\saus@semester}{}
\newcommand{\saus@session}{}
\newcommand{\saus@examdate}{}
\newcommand{\saus@duration}{}
\newcommand{\saus@totalmarks}{}
\newcommand{\saus@teacher}{}
\newcommand{\saus@credits}{}
\newcommand{\saus@examtitle}{}

% \examcourse{CS-201}{Data Structures and Algorithms}
\newcommand{\examcourse}[2]{%
  \renewcommand{\saus@coursecode}{#1}\renewcommand{\saus@coursetitle}{#2}}
\newcommand{\examprogramme}[1]{\renewcommand{\saus@programme}{#1}}
\newcommand{\examsemester}[1]{\renewcommand{\saus@semester}{#1}}
\newcommand{\examsession}[1]{\renewcommand{\saus@session}{#1}}
\newcommand{\examdate}[1]{\renewcommand{\saus@examdate}{#1}}
\newcommand{\examduration}[1]{\renewcommand{\saus@duration}{#1}}
\newcommand{\exammarks}[1]{\renewcommand{\saus@totalmarks}{#1}}
\newcommand{\examteacher}[1]{\renewcommand{\saus@teacher}{#1}}
\newcommand{\examcredits}[1]{\renewcommand{\saus@credits}{#1}}
% Overrides the wording that type= chooses
\newcommand{\examtitle}[1]{\renewcommand{\saus@examtitle}{#1}}

% Paper wording from type=
\newcommand{\saus@typename}{Examination}
\ifdefstring{\sausexam@type}{mid}{\renewcommand{\saus@typename}{Mid-Term Examination}}{}
\ifdefstring{\sausexam@type}{final}{\renewcommand{\saus@typename}{Final-Term Examination}}{}
\ifdefstring{\sausexam@type}{sessional}{\renewcommand{\saus@typename}{Sessional Examination}}{}
\ifdefstring{\sausexam@type}{quiz}{\renewcommand{\saus@typename}{Quiz}}{}
\ifdefstring{\sausexam@type}{makeup}{\renewcommand{\saus@typename}{Make-Up Examination}}{}
\ifdefstring{\sausexam@type}{supplementary}{\renewcommand{\saus@typename}{Supplementary Examination}}{}
\ifdefstring{\sausexam@type}{practical}{\renewcommand{\saus@typename}{Practical Examination}}{}

\newcommand{\saus@papername}{%
  \ifdefempty{\saus@examtitle}{\saus@typename}{\saus@examtitle}}

%%--------------------------------------------------------------------------
%% 4. SMALL PIECES OF FURNITURE
%%--------------------------------------------------------------------------
% A field label: small letterspaced maroon capitals
\newcommand{\saus@lab}[1]{%
  {\color{sausmaroon}\sauslabelfont\fontsize{7.6}{9}\selectfont
   \sausls{\MakeUppercase{#1}}}}

% A tinted panel the width of the text block
\newcommand{\saus@panel}[2][sausmist]{%
  \par\noindent
  \fcolorbox{sausrule}{#1}{%
    \begin{minipage}{\dimexpr\linewidth-2\fboxsep-2\fboxrule\relax}
      \vskip1.5pt #2\vskip1.5pt
    \end{minipage}}\par}

% A rule to write on
\newcommand{\sausblank}[1][30mm]{%
  \leavevmode\raisebox{-0.35em}{\color{sausslate}\rule{#1}{0.4pt}}}

% Start a new page unless #1 of the current one is still free, so that a
% question never stands alone at the foot. (The needspace package does the
% same; this is the whole of what is needed here, without the dependency.)
\newcommand{\saus@needspace}[1]{%
  \par
  \ifdim\pagegoal=\maxdimen\else
    \begingroup
      \setlength{\dimen@}{#1}%
      \ifdim\dimen@>\dimexpr\pagegoal-\pagetotal\relax\newpage\fi
    \endgroup
  \fi}

%%--------------------------------------------------------------------------
%% 5. THE HEADING
%%    \makeexamhead prints the crest block, the paper title, a grid of the
%%    details that are set (empty ones are skipped) and, with student=1,
%%    the roll number strip.
%%--------------------------------------------------------------------------
\newcommand{\saus@inforows}{}
\newcount\saus@infoc
\newcommand{\saus@info}[2]{%
  \advance\saus@infoc by 1
  \ifodd\saus@infoc
    \g@addto@macro\saus@inforows{\saus@lab{#1}&#2&}%
  \else
    \g@addto@macro\saus@inforows{\saus@lab{#1}&#2\\\hline}%
  \fi}
\newcommand{\saus@infoflush}{%
  \ifodd\saus@infoc\g@addto@macro\saus@inforows{&\\\hline}\fi}

% An extra detail the standard fields do not cover, e.g.
% \examinfo{Venue}{Examination Hall 2}. Kept aside and added to the grid
% after the standard fields, whether it is given before or after them.
\newcommand{\saus@extrainfo}{}
\newcommand{\examinfo}[2]{\g@addto@macro\saus@extrainfo{\saus@info{#1}{#2}}}

\newcommand{\saus@crestblock}{%
  \begin{minipage}[c]{21mm}
    \includegraphics[width=\linewidth]{\sauslogo}%
  \end{minipage}%
  \hspace{5mm}%
  \begin{minipage}[c]{\dimexpr\linewidth-26mm-44mm\relax}\raggedright
    {\color{sausmaroon}\fontsize{11.5}{14}\selectfont\sausdisplayfamily
     \sausdisplayseries\sausls{\MakeUppercase{\saus@university}}\par}%
    \vskip1.2mm
    {\color{sausmaroonlight}\fontsize{11}{13}\selectfont\sausmottofont
     \saus@motto\par}%
    \ifdefempty{\saus@department}{}{%
      \vskip2mm
      {\color{sausslate}\fontsize{8.5}{10}\selectfont\sauslabelfont
       \sausls{\MakeUppercase{\saus@department}}\par}}%
  \end{minipage}%
  \hfill
  \begin{minipage}[c]{43mm}\raggedleft
    {\color{sausmaroon}\fontsize{11}{21}\selectfont\saus@nativestack\par}%
  \end{minipage}\par
  \vskip3.5mm\sausrule\par}

\newcommand{\saus@papertitle}{%
  \vskip3mm
  \begingroup\centering
    {\color{sausmaroon}\sausdisplayfamily\sausdisplayseries
     \fontsize{15}{18}\selectfont
     \sausls{\MakeUppercase{\saus@papername}}\par}%
    \ifdefempty{\saus@session}{}{%
      \vskip1.2mm
      {\color{sausslate}\sauslightfont\fontsize{10.5}{13}\selectfont
       \saus@session\par}}%
    \ifsaus@solutions
      \vskip1.8mm
      {\setlength{\fboxsep}{3pt}%
       \colorbox{sausgreen}{\color{white}\sauslabelfont\footnotesize
         \sausls{MODEL ANSWER KEY}}\par}%
    \fi
  \endgroup
  \vskip3mm}

\newcommand{\saus@infogrid}{%
  \saus@infoc=0
  \gdef\saus@inforows{}%
  \ifdefempty{\saus@coursecode}{}{\saus@info{Course code}{\saus@coursecode}}%
  \ifdefempty{\saus@coursetitle}{}{\saus@info{Course title}{\saus@coursetitle}}%
  \ifdefempty{\saus@programme}{}{\saus@info{Programme}{\saus@programme}}%
  \ifdefempty{\saus@semester}{}{\saus@info{Semester}{\saus@semester}}%
  \ifdefempty{\saus@credits}{}{\saus@info{Credit hours}{\saus@credits}}%
  \ifdefempty{\saus@teacher}{}{\saus@info{Course teacher}{\saus@teacher}}%
  \ifdefempty{\saus@examdate}{}{\saus@info{Date}{\saus@examdate}}%
  \ifdefempty{\saus@duration}{}{\saus@info{Time allowed}{\saus@duration}}%
  \ifdefempty{\saus@totalmarks}{}{\saus@info{Total marks}{\saus@totalmarks}}%
  \saus@extrainfo
  \saus@infoflush
  \begingroup
    \setlength{\extrarowheight}{2.4pt}%
    \small
    \begin{tabularx}{\linewidth}{%
        |>{\raggedright\arraybackslash}p{23mm}|>{\raggedright\arraybackslash}X%
        |>{\raggedright\arraybackslash}p{23mm}|>{\raggedright\arraybackslash}X|}
      \hline
      \saus@inforows
    \end{tabularx}%
  \endgroup\par}

% Roll number strip: filled in by the candidate before the paper starts
\newcommand{\saus@studentstrip}{%
  \vskip2.5mm
  \saus@panel{%
    \small
    \saus@lab{Roll No.}~\sausblank[30mm]\hfill
    \saus@lab{Name}~\sausblank[48mm]\hfill
    \saus@lab{Signature}~\sausblank[28mm]}%
  \par}

\newcommand{\makeexamhead}{%
  \thispagestyle{saus@first}%
  \saus@crestblock
  \saus@papertitle
  \saus@infogrid
  \ifsaus@student\saus@studentstrip\fi
  \vskip1mm}

%%--------------------------------------------------------------------------
%% 6. INSTRUCTIONS
%%--------------------------------------------------------------------------
\NewEnviron{instructions}[1][Instructions]{%
  \par\vskip1mm
  \saus@panel{%
    \small
    {\color{sausmaroon}\sauslabelfont\fontsize{7.6}{9}\selectfont
     \sausls{\MakeUppercase{#1}}\par}\vskip0.8mm
    \begin{enumerate}[label={\color{sausmaroon}\bfseries\arabic*.},
        leftmargin=*,itemsep=1.5pt,topsep=0pt,parsep=0pt,partopsep=0pt]
      \BODY
    \end{enumerate}}%
  \par\vskip1mm}

%%--------------------------------------------------------------------------
%% 7. SECTIONS OF THE PAPER
%%    \examsection[10 marks]{Section A: Multiple Choice}
%%--------------------------------------------------------------------------
\newcommand{\examsection}[2][]{%
  \saus@closequestion
  \par\vskip2mm
  \saus@needspace{5\baselineskip}% a section never opens at the foot of a page
  \noindent\colorbox{sausmaroon}{%
    \begin{minipage}{\dimexpr\linewidth-2\fboxsep\relax}
      \vskip1.5pt
      {\color{white}\sausdisplayfamily\sausdisplayseries\small
       \sausls{\MakeUppercase{#2}}\hfill
       \ifstrempty{#1}{}{{\sauslightfont\color{sausgold}#1}}}%
      \vskip1.5pt
    \end{minipage}}\par\vskip1mm}

%%--------------------------------------------------------------------------
%% 8. QUESTIONS
%%    \question[marks=5, clo=2, bloom=Apply, topic=Recursion]  Q1, Q2, ...
%%    \qpart[marks=3]                                          (a), (b), ...
%%    The marks and the CLO sit in the right margin, clear of the text, and
%%    are added up for the marks table and the total check. A question runs
%%    until the next question, the next section or the end of the paper.
%%--------------------------------------------------------------------------
\newcounter{question}
\newcounter{qpart}[question]
\renewcommand{\thequestion}{\arabic{question}}
\renewcommand{\theqpart}{\alph{qpart}}

\define@key{sausq}{marks}{\def\saus@qmarks{#1}}
\define@key{sausq}{clo}{\def\saus@qclo{#1}}
\define@key{sausq}{bloom}{\def\saus@qbloom{#1}}
\define@key{sausq}{topic}{\def\saus@qtopic{#1}}
% Room for the candidate to write, left at the end of this question or part
\define@key{sausq}{lines}{\def\saus@qlines{#1}}
\define@key{sausq}{space}{\def\saus@qspace{#1}}
\define@boolkey{sausq}{bonus}[true]{}
\newcommand{\saus@qreset}{%
  \def\saus@qmarks{}\def\saus@qclo{}\def\saus@qbloom{}\def\saus@qtopic{}%
  \def\saus@qlines{}\def\saus@qspace{}%
  \KV@sausq@bonusfalse}
\saus@qreset

% Running totals are global: a question may sit inside a list or a minipage.
% Marks given to a question already cover its parts, so part marks are only
% added when the question itself carries none -- put the marks on the
% question, on its parts, or on both, and the total comes out right either way.
\newcommand{\saus@marksum}{0}
\newif\ifsaus@qhasmarks
\newcommand{\saus@addmarks}{%
  \ifdefempty{\saus@qmarks}{}{%
    \xdef\saus@marksum{\fpeval{\saus@marksum+\saus@qmarks}}}}

% The margin note: the marks, then the CLO and the cognitive level under them.
% It is set to no height and no depth, so a three-line note never opens up
% the line of text it sits beside.
\newcommand{\saus@marksnote}{%
  \ifdefempty{\saus@qmarks}{}{%
    \makebox[0pt][l]{%
      \hspace{\dimexpr\linewidth+\marginparsep\relax}%
      \raisebox{\z@}[\z@][\z@]{%
      \parbox[t]{\marginparwidth}{\raggedright
        {\color{sausmaroon}\sausdisplayfamily\sausdisplayseries\small
         \saus@qmarks\,{\fontsize{7}{8}\selectfont
         \ifdefstring{\saus@qmarks}{1}{mark}{marks}}\par}%
        \ifsaus@clo
          \ifdefempty{\saus@qclo}{}{%
            \vskip0.5mm{\color{sausslate}\fontsize{7}{8.5}\selectfont
              \sauslabelfont CLO~\saus@qclo\par}}%
          \ifdefempty{\saus@qbloom}{}{%
            {\color{sausslate}\fontsize{7}{8.5}\selectfont
              \sauslightfont\saus@qbloom\par}}%
        \fi}}}}}

% One row of the marks table, remembered in the .aux for the next run
\newcommand{\saus@recordq}{%
  \ifdefempty{\saus@qmarks}{}{%
    \protected@write\@auxout{}{%
      \string\saus@markrow{\thequestion}{\saus@qmarks}{\saus@qclo}%
        {\saus@qbloom}{\saus@qtopic}%
        {\ifKV@sausq@bonus1\else0\fi}}}}

\newlength{\saus@qindent}
\setlength{\saus@qindent}{13mm}

\newif\ifsaus@qopen
\newif\ifsaus@popen
% Answer space asked for with lines= or space= is left when the question or
% the part ends, which is where the candidate writes.
\newcommand{\saus@qpendlines}{}\newcommand{\saus@qpendspace}{}
\newcommand{\saus@ppendlines}{}\newcommand{\saus@ppendspace}{}
\newcommand{\saus@flushspace}[2]{%
  \ifdefempty{#1}{}{\answerlines{#1}\gdef#1{}}%
  \ifdefempty{#2}{}{\answerspace[#2]\gdef#2{}}}
\newcommand{\saus@keepspace}[2]{%
  \global\let#1\saus@qlines\global\let#2\saus@qspace}

% A part's marks are set at the end of the part, right up against the margin.
% The question's own marks are already in the margin beside its first line,
% and two margin notes a line apart would collide.
\newcommand{\saus@pmarks}{}
\newcommand{\saus@pclo}{}
\newcommand{\saus@partmarksline}{%
  \ifdefempty{\saus@pmarks}{}{%
    \unskip\nobreak\hfill\penalty50
    {\color{sausmaroon}\sausdisplayfamily\sausdisplayseries\small
     [\saus@pmarks\space\ifdefstring{\saus@pmarks}{1}{mark}{marks}%
      \ifsaus@clo
        \ifdefempty{\saus@pclo}{}{\saus@sep CLO~\saus@pclo}%
      \fi]}\par
    \gdef\saus@pmarks{}\gdef\saus@pclo{}}}

\newcommand{\saus@closepart}{%
  \ifsaus@popen
    \saus@partmarksline
    \saus@flushspace{\saus@ppendlines}{\saus@ppendspace}%
    \end{list}\saus@popenfalse
  \fi}
\newcommand{\saus@closequestion}{%
  \saus@closepart
  \ifsaus@qopen
    \saus@flushspace{\saus@qpendlines}{\saus@qpendspace}%
    \end{list}\saus@qopenfalse
  \fi}

\newcommand{\question}[1][]{%
  \saus@closequestion
  \saus@qreset
  \setkeys{sausq}{#1}%
  \stepcounter{question}%
  \global\saus@qhasmarksfalse
  \ifKV@sausq@bonus\else
    \ifdefempty{\saus@qmarks}{}{\global\saus@qhasmarkstrue}\saus@addmarks
  \fi
  \saus@recordq
  \saus@keepspace{\saus@qpendlines}{\saus@qpendspace}%
  \par\vskip0.5\baselineskip
  \saus@needspace{3\baselineskip}% never leave a question alone at the foot
  \begin{list}{}{%
    \setlength{\leftmargin}{\saus@qindent}%
    \setlength{\rightmargin}{0pt}%
    \setlength{\labelwidth}{\dimexpr\saus@qindent-0.8em\relax}%
    \setlength{\labelsep}{0.8em}%
    \setlength{\itemindent}{0pt}\setlength{\listparindent}{0pt}%
    \setlength{\topsep}{0pt}\setlength{\parsep}{0.4\baselineskip}%
    \setlength{\partopsep}{0pt}\setlength{\itemsep}{0pt}}%
  \saus@qopentrue
  \item[{\color{sausmaroon}\sausdisplayfamily\sausdisplayseries
         Q\thequestion.}]%
  \saus@marksnote
  \ifKV@sausq@bonus
    {\color{sausgold}\sauslabelfont\fontsize{7.6}{9}\selectfont
     \sausls{BONUS}\hspace{0.6em}}%
  \fi
  \ignorespaces}

% (a), (b), ... inside a question
\newcommand{\qpart}[1][]{%
  \saus@closepart
  \saus@qreset
  \setkeys{sausq}{#1}%
  \ifKV@sausq@bonus\else\ifsaus@qhasmarks\else\saus@addmarks\fi\fi
  \saus@keepspace{\saus@ppendlines}{\saus@ppendspace}%
  % printed at the end of this part: its marks, and its CLO when one is given
  \global\let\saus@pmarks\saus@qmarks
  \global\let\saus@pclo\saus@qclo
  \stepcounter{qpart}%
  \par\vskip0.25\baselineskip
  \begin{list}{}{%
    \setlength{\leftmargin}{8mm}\setlength{\rightmargin}{0pt}%
    \setlength{\labelwidth}{7mm}\setlength{\labelsep}{1mm}%
    \setlength{\itemindent}{0pt}\setlength{\listparindent}{0pt}%
    \setlength{\topsep}{0pt}\setlength{\parsep}{0.3\baselineskip}%
    \setlength{\partopsep}{0pt}\setlength{\itemsep}{0pt}}%
  \saus@popentrue
  \item[{\color{sausmaroon}\bfseries(\theqpart)}]%
  \ignorespaces}

%%--------------------------------------------------------------------------
%% 9. MULTIPLE CHOICE
%%    \begin{choices}[cols=4] \choice ... \correctchoice ... \end{choices}
%%    The correct one is marked only when the paper is built with
%%    solutions=1, so the same file gives the paper and the key.
%%--------------------------------------------------------------------------
\newcounter{choice}
\define@key{sauschoices}{cols}{\def\saus@choicecols{#1}}
\newif\ifsaus@choiceopen
\newcommand{\saus@closechoice}{%
  \ifsaus@choiceopen\end{minipage}\saus@choiceopenfalse
    \hspace{0.8em}\penalty0\hskip0pt\relax\fi}
\newcommand{\saus@choice}[1]{%
  \saus@closechoice
  \stepcounter{choice}%
  \begin{minipage}[t]{\saus@choicewidth}\raggedright\saus@choiceopentrue
    % the strut opens the line before any colour change, so every choice in
    % the row sits on the same baseline, marked or not
    \strut
    \ifnum#1=1\relax\ifsaus@solutions\color{sausgreen}\bfseries\fi\fi
    (\alph{choice})~\ignorespaces}
\newenvironment{choices}[1][]{%
  \def\saus@choicecols{2}%
  \setkeys{sauschoices}{#1}%
  \par\vskip0.15\baselineskip
  \setlength{\parskip}{0pt}%
  \rightskip=0pt plus 1fil\relax
  \parfillskip=0pt plus 1fil\relax
  \setcounter{choice}{0}%
  \edef\saus@choicewidth{\the\dimexpr
    \linewidth/\saus@choicecols-1em\relax}%
  \let\choice\saus@choicezero
  \let\correctchoice\saus@choiceone
  \ignorespaces}{%
  \saus@closechoice\par\vskip0.15\baselineskip}
\newcommand{\saus@choicezero}{\saus@choice{0}}
\newcommand{\saus@choiceone}{\saus@choice{1}}

%%--------------------------------------------------------------------------
%% 10. ANSWER SPACE
%%--------------------------------------------------------------------------
% Empty space to write in
\newcommand{\answerspace}[1][35mm]{\par\vspace*{#1}\par}
% #1 ruled lines to write on
\newcommand{\answerlines}[1]{%
  \par\vskip0.3\baselineskip
  \begingroup
    \setlength{\parskip}{0pt}%
    \color{sausrule}\count@=#1\relax
    \loop\ifnum\count@>0
      \noindent\rule{\linewidth}{0.4pt}\par\nointerlineskip\vskip8mm
      \advance\count@ by \m@ne
    \repeat
  \endgroup\par\vskip-8mm\vskip0.3\baselineskip}
% A framed box for a worked answer, a drawing or a table
\newcommand{\answerbox}[1][40mm]{%
  \par\vskip0.3\baselineskip
  \noindent\fcolorbox{sausrule}{white}{%
    \begin{minipage}[t][#1][t]{\dimexpr\linewidth-2\fboxsep-2\fboxrule\relax}%
      \strut
    \end{minipage}}\par}

%%--------------------------------------------------------------------------
%% 11. MODEL ANSWERS
%%     Printed only with solutions=1, so one file is both paper and key.
%%--------------------------------------------------------------------------
\ifsaus@solutions
  \NewEnviron{solution}[1][Answer]{%
    \par\vskip0.3\baselineskip
    \saus@panel[sausgreen!7]{%
      \small
      {\color{sausgreen}\sauslabelfont\fontsize{7.6}{9}\selectfont
       \sausls{\MakeUppercase{#1}}\par}\vskip0.6mm
      \BODY}%
    \par\vskip0.2\baselineskip}
\else
  \NewEnviron{solution}[1][Answer]{}
\fi

%%--------------------------------------------------------------------------
%% 12. MARKS AND CLO DISTRIBUTION
%%     Every question records itself in the .aux file; \sausmarkstable
%%     typesets what the previous run collected, so two runs settle it.
%%--------------------------------------------------------------------------
\newcommand{\saus@marklist}{}
\newcommand{\saus@auxsum}{0}
% #6 = 1 for a bonus question: shown as "+n" and left out of the total
\newcount\saus@nq                        % questions the last run recorded
\newcommand{\saus@markrow}[6]{%
  \g@addto@macro\saus@marklist{\saus@markline{#1}{#2}{#3}{#4}{#5}{#6}}%
  \global\advance\saus@nq by 1
  \ifnum#6=1\relax\else\xdef\saus@auxsum{\fpeval{\saus@auxsum+#2}}\fi}
\newcommand{\sausmarksformat}[1]{\fpeval{round(#1,2)}}

\newcommand{\sausmarkstable}[1][Marks and CLO distribution]{%
  \par\vskip1mm
  \begingroup
    \small
    {\color{sausmaroon}\sauslabelfont\fontsize{7.6}{9}\selectfont
     \sausls{\MakeUppercase{#1}}\par}\vskip1mm
    \setlength{\extrarowheight}{2.2pt}%
    \def\saus@markline##1##2##3##4##5##6{%
      ##1&##5&\ifstrempty{##3}{}{CLO~##3}&##4&
      \ifnum##6=1\relax{\color{sausgold}+##2}\else##2\fi\\\hline}%
    \begin{tabularx}{\linewidth}{|>{\centering\arraybackslash}p{17mm}|%
        >{\raggedright\arraybackslash}X|%
        >{\raggedright\arraybackslash}p{16mm}|%
        >{\raggedright\arraybackslash}p{22mm}|%
        >{\raggedleft\arraybackslash}p{12mm}|}
      \hline
      \rowcolor{sausmist}
      \saus@lab{Question}&\saus@lab{Topic}&\saus@lab{CLO}&
      \saus@lab{Level}&\saus@lab{Marks}\\\hline
      \saus@marklist
      \rowcolor{sausmist}
      \multicolumn{4}{|r|}{\saus@lab{Total}}&
      {\bfseries\sausmarksformat{\saus@auxsum}}\\\hline
    \end{tabularx}%
  \endgroup\par}

% The examiner's grid: one column per question for the marks awarded, and a
% box for the total. Put it on the front page of a paper that is answered on
% the question paper itself. It also needs two runs.
\newcommand{\sausmarksgrid}[1][For the examiner only]{%
  \par\vskip1mm
  \begingroup
    \small
    \setlength{\extrarowheight}{3pt}%
    \def\saus@gridnum{}\def\saus@gridblank{}%
    \def\saus@markline##1##2##3##4##5##6{%
      \g@addto@macro\saus@gridnum{&##1}%
      \g@addto@macro\saus@gridblank{&}}%
    \saus@marklist
    \noindent\fcolorbox{sausrule}{white}{%
      \begin{minipage}{\dimexpr\linewidth-2\fboxsep-2\fboxrule\relax}
        \vskip1.5pt
        {\color{sausmaroon}\sauslabelfont\fontsize{7.6}{9}\selectfont
         \sausls{\MakeUppercase{#1}}\par}\vskip1.2mm
        \ifnum\saus@nq>0
          % X columns divide whatever is left between the questions, so the
          % grid fits the page whether there are four questions or fourteen
          \setlength{\tabcolsep}{3pt}%
          \begin{tabularx}{\linewidth}{|>{\raggedright\arraybackslash}p{26mm}|%
              *{\the\saus@nq}{>{\centering\arraybackslash}X|}%
              >{\centering\arraybackslash}p{13mm}|}
            \hline
            \rowcolor{sausmist}\saus@lab{Question}\saus@gridnum&\saus@lab{Total}\\
            \hline
            \saus@lab{Marks awarded}\saus@gridblank&\\[4.5ex]
            \hline
          \end{tabularx}
        \else
          \ClassWarningNoLine{saus-exam}{Rerun to fill the examiner's grid}%
        \fi
        \par\vskip2mm
        {\fontsize{8}{10}\selectfont\color{sausslate}%
         Examiner's signature~\sausblank[34mm]\hfill
         Date~\sausblank[26mm]}%
        \vskip1.5pt
      \end{minipage}}%
  \endgroup\par}

%%--------------------------------------------------------------------------
%% 13. HEAD, FOOT AND THE END OF THE PAPER
%%--------------------------------------------------------------------------
\newcommand{\saus@footfont}{\fontsize{8}{10}\selectfont\color{sausslate}}
\fancypagestyle{saus@first}{%
  \fancyhf{}\renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0.4pt}%
  \fancyfoot[L]{\saus@footfont
    \ifdefempty{\saus@coursecode}{}{\saus@coursecode\saus@sep}\saus@papername}%
  \fancyfoot[C]{\saus@footfont Page~\thepage\ of~\pageref{LastPage}}%
  \fancyfoot[R]{\saus@footfont
    \ifdefempty{\saus@totalmarks}{}{Total marks:~\saus@totalmarks}}}

\fancypagestyle{saus@rest}{%
  \fancyhf{}\renewcommand{\headrulewidth}{0.4pt}%
  \renewcommand{\footrulewidth}{0.4pt}%
  \fancyhead[L]{%
    \raisebox{-0.32\height}{\includegraphics[height=7mm]{\sauslogo}}\hspace{2.5mm}%
    {\color{sausmaroon}\sauslabelfont\fontsize{8}{10}\selectfont
     \sausls{\MakeUppercase{\saus@shortuniversity}}}}%
  \fancyhead[R]{\saus@footfont
    \ifsaus@rollhead Roll No.~\sausblank[24mm]%
    \else\saus@coursecode\fi}%
  \fancyfoot[L]{\saus@footfont
    \ifdefempty{\saus@coursecode}{}{\saus@coursecode\saus@sep}\saus@papername}%
  \fancyfoot[C]{\saus@footfont Page~\thepage\ of~\pageref{LastPage}}%
  \fancyfoot[R]{\saus@footfont
    \ifdefempty{\saus@totalmarks}{}{Total marks:~\saus@totalmarks}}}

\renewcommand{\headrule}{{\color{sausrule}%
  \hrule height\headrulewidth width\headwidth}}
\renewcommand{\footrule}{{\color{sausrule}%
  \hrule height\footrulewidth width\headwidth}}
\pagestyle{saus@rest}

% The end marker, so a candidate knows nothing is missing. (It cannot be
% called \endofpaper: LaTeX reserves every name beginning with \end.)
\newcommand{\examend}[1][End of question paper]{%
  \saus@closequestion
  \par\vskip1\baselineskip
  \begingroup\centering
    {\color{sausmaroon}\rule{2.2em}{0.18em}}%
    {\color{sausgold}\rule{0.9em}{0.18em}}\par\vskip1.2mm
    {\color{sausslate}\sauslabelfont\footnotesize
     \sausls{\MakeUppercase{#1}}\par}%
  \endgroup\par}

\AtEndDocument{\saus@closequestion}
% The declared total and the questions must agree
\AtEndDocument{%
  \ifdefempty{\saus@totalmarks}{}{%
    \ifdim\fpeval{abs(\saus@marksum-\saus@totalmarks)}pt>0.001pt
      \ClassWarningNoLine{saus-exam}{The questions add up to
        \sausmarksformat{\saus@marksum}, but \string\exammarks\space says
        \saus@totalmarks}%
    \fi}}

\endinput
