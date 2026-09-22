%%==========================================================================
%%  saus-poster.cls
%%  Research-poster class for THE SHAIKH AYAZ UNIVERSITY, SHIKARPUR
%%  "Revival of Educational Glory of Shikarpur"
%%
%%  Shares colours, typography and identity with the slide theme through
%%  saus-brand.sty. Layout engine: the tcolorbox "poster" library.
%%
%%  Version 1.0 -- 2026-09-21
%%  Build with LuaLaTeX (recommended) or XeLaTeX. pdfLaTeX also works,
%%  without Fira Math or Sindhi/Urdu.
%%==========================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{saus-poster}[2026/09/21 v1.0 Shaikh Ayaz University Shikarpur poster]

%%--------------------------------------------------------------------------
%% 1. OPTIONS
%%--------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sausposter,prefix=sausposter@}
% paper size: a0 | a1 | a2 | a3 (everything scales with it)
\DeclareStringOption[a0]{size}
% landscape instead of portrait
\DeclareBoolOption[false]{landscape}
% header = photo | solid | light  (mirrors the slide title styles)
\DeclareStringOption[photo]{header}
% photograph for header=photo, looked up in the assets folder
\DeclareStringOption[saus-title-bg.jpg]{headerimage}
% path (with trailing slash) to the shared assets folder
\DeclareStringOption[assets/]{assets}
% native = sindhi | urdu | both | none  (university name in the header)
\DeclareStringOption[sindhi]{native}
% use the brand typefaces
\DeclareBoolOption[true]{fonts}
% outline the layout grid while arranging boxes
\DeclareBoolOption[false]{grid}
\ProcessKeyvalOptions*
% Keep our key=value options away from packages that read class options.
\let\@classoptionslist\@empty
\let\@unusedoptionlist\@empty

% pdfLaTeX only: scalable Computer Modern for maths at poster sizes
% (must precede the base class). Xe/LuaLaTeX use Fira Math instead.
\RequirePackage{iftex}
\ifPDFTeX\RequirePackage{fix-cm}\fi

\LoadClass{article}

%%--------------------------------------------------------------------------
%% 2. PAGE, BRAND AND PACKAGES
%%--------------------------------------------------------------------------
\edef\saus@tmp{\noexpand\RequirePackage[\sausposter@size paper,%
  \ifsausposter@landscape landscape,\fi margin=0pt,noheadfoot]{geometry}}
\saus@tmp
\edef\saus@tmp{\noexpand\RequirePackage[assets=\sausposter@assets,%
  native=\sausposter@native,fonts=\ifsausposter@fonts true\else false\fi]{saus-brand}}
\saus@tmp

\RequirePackage{tikz}
\usetikzlibrary{calc,fadings}
\RequirePackage{tcolorbox}
\tcbuselibrary{skins,poster}   % only what is used; [most] would pull in listings
\RequirePackage{ragged2e}
\RequirePackage{enumitem}
\RequirePackage{booktabs}
\RequirePackage{caption}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage[link]{qrcode}

\renewcommand{\familydefault}{\sfdefault}
\pagestyle{empty}
\setlength{\parindent}{0pt}

%%--------------------------------------------------------------------------
%% 3. SCALE
%%    \saus@u is 1% of the paper's short side (8.41 mm on A0), and every
%%    dimension below is a multiple of it -- so A1 is an exact scaled A0.
%%--------------------------------------------------------------------------
\newlength{\saus@u}
\newlength{\saus@base}
\newlength{\saus@margin}
\newlength{\saus@gap}
\newlength{\saus@bodyh}
\newcommand{\saus@setscale}{%
  \setlength{\saus@u}{0.01\dimexpr\ifdim\paperwidth<\paperheight\paperwidth\else\paperheight\fi\relax}%
  \setlength{\saus@base}{1.2\saus@u}%       28.6 pt body text on A0
  \setlength{\saus@margin}{3.6\saus@u}%
  \setlength{\saus@gap}{2.4\saus@u}%
  \setlength{\parskip}{0.55\saus@base}%
  % \tiny ... \Huge become a modular scale around the base size
  \tcbset{fit fontsize macros}\tcbsetforeverylayer{fit basedim=\saus@base}%
  \normalsize}
\AtBeginDocument{\saus@setscale}

% Font size as a multiple of the body size: \saus@fs{size}{leading}
\newcommand{\saus@fs}[2]{%
  \fontsize{\the\dimexpr#1\saus@base\relax}{\the\dimexpr#2\saus@base\relax}\selectfont}

%%--------------------------------------------------------------------------
%% 4. POSTER METADATA
%%    \title, \author (article) plus the commands below; \sausdepartment,
%%    \sausevent and the other identity commands come from saus-brand.sty.
%%--------------------------------------------------------------------------
\newcommand{\saus@subtitle}{}
\newcommand{\subtitle}[1]{\renewcommand{\saus@subtitle}{#1}}
\newcommand{\saus@affiliation}{}
\newcommand{\affiliation}[1]{\renewcommand{\saus@affiliation}{#1}}
\newcommand{\saus@contact}{}
\newcommand{\sauscontact}[1]{\renewcommand{\saus@contact}{#1}}
% QR code in the footer: \sausqr{url}{label}; \sausqr{}{} removes it
\newcommand{\saus@qrurl}{https://saus.edu.pk}
\newcommand{\saus@qrlabel}{saus.edu.pk}
\newcommand{\sausqr}[2]{\renewcommand{\saus@qrurl}{#1}\renewcommand{\saus@qrlabel}{#2}}

%%--------------------------------------------------------------------------
%% 5. HEADER
%%--------------------------------------------------------------------------
\newcommand{\saus@headercolors}{%
  \ifdefstring{\sausposter@header}{light}{%
    \colorlet{saus@hbg}{sausmist}\colorlet{saus@hfg}{sausink}%
    \colorlet{saus@htitle}{sausmaroon}\colorlet{saus@hsubtle}{sausslate}%
    \colorlet{saus@hlabel}{sausmaroon}\colorlet{saus@hmotto}{sausmaroonlight}%
    \def\saus@hcrest{\sauslogo}%
  }{%
    \colorlet{saus@hbg}{sausmaroondark}\colorlet{saus@hfg}{white}%
    \colorlet{saus@htitle}{white}\colorlet{saus@hsubtle}{sausmist}%
    \colorlet{saus@hlabel}{sausgold}\colorlet{saus@hmotto}{sausgold}%
    \def\saus@hcrest{\sauslogowhite}%
  }}

\newcommand{\saus@headerbackground}{%
  \fill[saus@hbg] (interior.south west) rectangle (interior.north east);
  \begin{scope}
    \clip (interior.south west) rectangle (interior.north east);
    \ifdefstring{\sausposter@header}{photo}{%
      \node[inner sep=0pt] at (interior.center)
        {\includegraphics[width=\paperwidth]{\saus@assets\sausposter@headerimage}};
      \fill[sausmaroondark,opacity=0.86] (interior.south west) rectangle (interior.north east);
      \fill[sausmaroondark,opacity=0.50,path fading=east]
        (interior.south west) rectangle (interior.north east);
    }{}%
    \ifdefstring{\sausposter@header}{solid}{%
      \node[anchor=east,inner sep=0pt,opacity=0.08]
        at ([xshift=6\saus@u]interior.east)
        {\includegraphics[height=48\saus@u]{\sauslogowhite}};
      \fill[sausmaroon,opacity=0.40,path fading=east]
        (interior.south west) rectangle (interior.north east);
    }{}%
  \end{scope}
  \fill[sausgold] (interior.south west) rectangle ([yshift=0.45\saus@u]interior.south east);
}

\newsavebox{\saus@headerbox}
\newlength{\saus@crestw}
\newlength{\saus@sidew}
\newlength{\saus@titlew}
\newcommand{\saus@buildheader}{%
  \saus@headercolors
  \setlength{\saus@crestw}{12\saus@u}%
  \setlength{\saus@sidew}{0.24\dimexpr\paperwidth-2\saus@margin\relax}%
  \setlength{\saus@titlew}{\dimexpr\paperwidth-2\saus@margin-\saus@crestw-\saus@sidew-6\saus@u\relax}%
  \setbox\saus@headerbox=\vbox{\hsize=\paperwidth
    \begin{tcolorbox}[enhanced,nobeforeafter,width=\paperwidth,sharp corners,
        boxrule=0pt,frame hidden,boxsep=0pt,
        left=\saus@margin,right=\saus@margin,top=3.4\saus@u,bottom=3.9\saus@u,
        interior code={\saus@headerbackground}]
      \begin{minipage}[c]{\saus@crestw}
        \includegraphics[width=\linewidth]{\saus@hcrest}%
      \end{minipage}%
      \hspace{3\saus@u}%
      \begin{minipage}[c]{\saus@titlew}\saus@nohyphen\RaggedRight
        {\color{saus@hfg}\saus@fs{0.92}{1.2}\sauslabelfont
         \sausls{\MakeUppercase{\saus@university}}\par}%
        \vskip0.9\saus@base
        {\color{saus@htitle}\saus@fs{3.1}{3.35}\sausdisplayfamily\sausdisplayseries
         \@title\par}%
        \ifx\saus@subtitle\@empty\else
          \vskip0.45\saus@base
          {\color{saus@hsubtle}\saus@fs{1.55}{1.85}\sauslightfont\saus@subtitle\par}%
        \fi
        \vskip1.1\saus@base
        {\color{saus@hfg}\saus@fs{1.25}{1.6}\sauslabelfont\@author\par}%
        \ifx\saus@affiliation\@empty
          \ifx\saus@department\@empty\else
            \vskip0.25\saus@base
            {\color{saus@hsubtle}\saus@fs{0.95}{1.3}\saus@department\par}%
          \fi
        \else
          \vskip0.25\saus@base
          {\color{saus@hsubtle}\saus@fs{0.95}{1.3}\saus@affiliation\par}%
        \fi
      \end{minipage}%
      \hfill
      \begin{minipage}[c]{\saus@sidew}\RaggedLeft
        \ifx\saus@nativename\@empty\else
          {\color{saus@hfg}\saus@fs{1.45}{2.3}\saus@nativestack\par}%
          \vskip0.2\saus@base
        \fi
        {\color{saus@hmotto}\saus@fs{1.15}{1.4}\sausmottofont\saus@motto\par}%
        \ifx\saus@event\@empty\else
          \vskip1.0\saus@base
          {\color{saus@hlabel}\saus@fs{0.85}{1.3}\sauslabelfont
           \sausls{\MakeUppercase{\saus@event}}\par}%
        \fi
      \end{minipage}%
    \end{tcolorbox}}}

%%--------------------------------------------------------------------------
%% 6. FOOTER
%%--------------------------------------------------------------------------
\newsavebox{\saus@footerbox}
\newcommand{\saus@buildfooter}{%
  \setbox\saus@footerbox=\vbox{\hsize=\paperwidth
    \begin{tcolorbox}[enhanced,nobeforeafter,width=\paperwidth,sharp corners,
        boxrule=0pt,frame hidden,boxsep=0pt,colback=sausmaroondark,
        left=\saus@margin,right=\saus@margin,top=2.3\saus@u,bottom=2.3\saus@u,
        overlay={\fill[sausgold] (frame.north west) rectangle
                   ([yshift=-0.45\saus@u]frame.north east);}]
      \color{white}%
      % crest + name + contact line
      \begin{minipage}[c]{6.2\saus@u}
        \includegraphics[width=\linewidth]{\sauslogowhite}%
      \end{minipage}%
      \hspace{2\saus@u}%
      \begin{minipage}[c]{0.46\linewidth}\RaggedRight
        {\saus@fs{0.9}{1.3}\sauslabelfont\sausls{\MakeUppercase{\saus@university}}\par}%
        \vskip0.2\saus@base
        {\color{sausgold}\saus@fs{1.0}{1.3}\sausmottofont\saus@motto\par}%
        \vskip0.35\saus@base
        {\color{sausmist}\saus@fs{0.8}{1.2}\saus@web\saus@sep\saus@address\saus@sep\saus@phone\par}%
      \end{minipage}%
      \hfill
      \ifx\saus@contact\@empty\else
        \begin{minipage}[c]{0.28\linewidth}\RaggedLeft
          {\color{sausgold}\saus@fs{0.75}{1.2}\sauslabelfont\sausls{CONTACT}\par}%
          \vskip0.2\saus@base
          {\saus@fs{0.95}{1.3}\saus@contact\par}%
        \end{minipage}%
      \fi
      \ifx\saus@qrurl\@empty\else
        \hspace{2.4\saus@u}%
        \begin{minipage}[c]{8.6\saus@u}\centering
          {\setlength{\fboxsep}{0.7\saus@u}%
           \colorbox{white}{\color{sausink}\qrcode[height=7.2\saus@u]{\saus@qrurl}}\par}%
          \vskip0.25\saus@base
          {\color{sausmist}\saus@fs{0.62}{0.9}\saus@qrlabel\par}%
        \end{minipage}%
      \fi
    \end{tcolorbox}}}

%%--------------------------------------------------------------------------
%% 7. CONTENT BOXES
%%    \sausbox   plain: maroon title over the signature rule (the default)
%%    \sauscard  the same on a mist card
%%    \sausaccent  deep maroon card with white text -- for key findings
%%    \sausblock  maroon title bar over a mist body, like a slide block
%%    All take  [tcolorbox options]{placement}{title}{content}
%%--------------------------------------------------------------------------
\colorlet{saus@bt}{sausmaroon}     % box title
\colorlet{saus@bhair}{sausrule}    % hairline of the title rule
\colorlet{saus@bmain}{sausmaroon}  % first segment of the title rule
\colorlet{saus@bullet}{sausmaroon} % list markers
\colorlet{saus@stat}{sausmaroon}   % \sausstat figures

% Overflow guard. A box stretched with "between=... and bottom" has a fixed
% height, and content that does not fit would silently spill over the boxes
% below or the footer. Each box's content is measured and a warning names
% the box that is too full. (\tcbtextheight is the space available in a
% fixed-height box and 0pt otherwise.)
\newbox\saus@probebox
\newcommand{\saus@probebegin}{\setbox\saus@probebox=\vbox\bgroup}
\newcommand{\saus@probeend}{%
  \egroup
  \ifdim\tcbtextheight<\z@
    \ClassWarningNoLine{saus-poster}{Box `\tcb@poster@boxname' has no room:
      the boxes above it already fill the column. Move a box to another
      column or shorten the content}%
  \else\ifdim\tcbtextheight>\z@
    \ifdim\dimexpr\ht\saus@probebox+\dp\saus@probebox\relax>\dimexpr\tcbtextheight+1pt\relax
      \ClassWarningNoLine{saus-poster}{Box `\tcb@poster@boxname' is too full by
        \the\dimexpr\ht\saus@probebox+\dp\saus@probebox-\tcbtextheight\relax.
        Shorten its content or move a box to another column}%
    \fi
  \fi\fi
  \unvbox\saus@probebox}

\newcommand{\saus@titlerule}{%
  \par\vskip0.35\saus@base
  {\saus@fs{1}{1}%
   \color{saus@bmain}\rule[0.073em]{1.46em}{0.2em}%
   \color{sausgold}\rule[0.073em]{0.64em}{0.2em}%
   \color{saus@bhair}\rule[0.146em]{\dimexpr\linewidth-2.1em\relax}{0.055em}}}

% The frame is filled in the box colour and the title strip is transparent,
% so title and body read as one surface with no seam between them.
\tcbset{
  saus@common/.style={enhanced,sharp corners,boxrule=0pt,boxsep=0pt,opacitybacktitle=0,
    fontupper=\normalsize,fonttitle=\sausdisplayfamily\sausdisplayseries\Large,
    titlerule=0pt,lefttitle=0pt,righttitle=0pt,toptitle=0pt,
    bottomtitle=0.9\saus@base,after title={\saus@titlerule},
    % ragged-right without hyphenation reads best at poster distance
    before upper={\RaggedRight\saus@nohyphen\parskip=0.55\saus@base\relax\saus@probebegin},
    after upper={\saus@probeend}},
  saus plain/.style={saus@common,colback=white,colframe=white,colbacktitle=white,
    coltitle=sausmaroon,coltext=sausink,left=0pt,right=0pt,top=0pt,bottom=0pt},
  saus card/.style={saus@common,colback=sausmist,colframe=sausmist,colbacktitle=sausmist,
    coltitle=sausmaroon,coltext=sausink,
    left=2\saus@u,right=2\saus@u,top=2\saus@u,bottom=2\saus@u,
    lefttitle=2\saus@u,righttitle=2\saus@u,toptitle=2\saus@u},
  saus accent/.style={saus@common,colback=sausmaroondark,colframe=sausmaroondark,
    colbacktitle=sausmaroondark,
    coltitle=white,coltext=white,
    left=2\saus@u,right=2\saus@u,top=2\saus@u,bottom=2\saus@u,
    lefttitle=2\saus@u,righttitle=2\saus@u,toptitle=2\saus@u,
    code={\colorlet{saus@bmain}{white}\colorlet{saus@bhair}{sausmaroonlight}%
          \colorlet{saus@bullet}{sausgold}\colorlet{saus@stat}{white}%
          \colorlet{saus@statlabel}{sausmist}}},
  saus block/.style={saus@common,colback=sausmist,colframe=sausmist,
    colbacktitle=sausmaroon,opacitybacktitle=1,
    coltitle=white,coltext=sausink,after title={},
    left=2\saus@u,right=2\saus@u,top=1.6\saus@u,bottom=2\saus@u,
    lefttitle=2\saus@u,righttitle=2\saus@u,toptitle=1.1\saus@u,bottomtitle=1.1\saus@u},
}

\newcommand{\saus@box}[5]{% #1 style, #2 options, #3 placement, #4 title, #5 content
  \ifblank{#4}%
    {\posterbox[#1,#2]{#3}{#5}}%
    {\posterbox[#1,title={#4},#2]{#3}{#5}}}
\newcommand{\sausbox}[4][]{\saus@box{saus plain}{#1}{#2}{#3}{#4}}
\newcommand{\sauscard}[4][]{\saus@box{saus card}{#1}{#2}{#3}{#4}}
\newcommand{\sausaccent}[4][]{\saus@box{saus accent}{#1}{#2}{#3}{#4}}
\newcommand{\sausblock}[4][]{\saus@box{saus block}{#1}{#2}{#3}{#4}}

% Figure with a numbered caption (floats cannot live inside boxes)
\newcommand{\sausfigure}[3][\linewidth]{%
  \par{\centering\includegraphics[width=#1]{#2}\par}%
  \captionof{figure}{#3}}

%%--------------------------------------------------------------------------
%% 8. LISTS AND CAPTIONS
%%--------------------------------------------------------------------------
\setlist{topsep=0.3\saus@base,itemsep=0.3\saus@base,parsep=0pt,partopsep=0pt,
  labelsep=0.6em,leftmargin=*}
\setlist[itemize,1]{label={\textcolor{saus@bullet}{\rule[0.16ex]{0.72ex}{0.72ex}}}}
\setlist[itemize,2]{label={\textcolor{sausblue}{\rule[0.2ex]{0.55ex}{0.55ex}}}}
\setlist[itemize,3]{label={\textcolor{sausgold}{\rule[0.24ex]{0.42ex}{0.42ex}}}}
\setlist[enumerate,1]{
  label={\textcolor{saus@bullet}{\sausdisplayfamily\sausdisplayseries\arabic*.}}}
\setlist[description]{font={\color{sausmaroon}\bfseries}}

\DeclareCaptionLabelSeparator{saus}{\enspace\textbar\enspace}
\captionsetup{font={small,color=sausslate},labelfont={bf,color=sausmaroon},
  labelsep=saus,justification=raggedright,singlelinecheck=false,skip=0.6\saus@base,
  hypcap=false}

%%--------------------------------------------------------------------------
%% 9. THE POSTER ENVIRONMENT
%%    \begin{sausposter}[<tcbposter poster keys, e.g. columns=4,rows=6>]
%%      \sausbox{name=intro,column=1,below=top}{Introduction}{...}
%%    \end{sausposter}
%%--------------------------------------------------------------------------
\newcommand{\saus@columns}{\ifsausposter@landscape 4\else 3\fi}

\newenvironment{sausposter}[1][]{%
  \saus@buildheader
  \saus@buildfooter
  % The body gets exactly the height left between header and footer
  \setlength{\saus@bodyh}{\dimexpr\paperheight
    -\ht\saus@headerbox-\dp\saus@headerbox
    -\ht\saus@footerbox-\dp\saus@footerbox-2\saus@gap-2pt\relax}%
  \parskip=0pt\relax
  \noindent\copy\saus@headerbox\par\nointerlineskip
  \vskip\saus@gap
  \noindent\hspace*{\saus@margin}%
  \begin{minipage}[t][\saus@bodyh][t]{\dimexpr\paperwidth-2\saus@margin\relax}%
    \tikz[remember picture,overlay]{%
      \node[anchor=south west,inner sep=0pt] at (current page.south west)
        {\usebox{\saus@footerbox}};}%
    \begin{tcbposter}[no coverage,
      poster={width=\linewidth,height=\saus@bodyh,columns=\saus@columns,rows=4,
        spacing=\saus@gap,showframe=\ifsausposter@grid true\else false\fi,#1},
      boxes={saus plain}]%
}{%
    \end{tcbposter}%
  \end{minipage}%
}

\endinput
