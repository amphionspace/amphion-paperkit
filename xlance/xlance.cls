% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LaTeX Style Template for X-LANCE pre-prints
% Version: 0.2.2
% Update date: 20260304
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% =============================================================================
% Class Declaration / 文档类声明
% =============================================================================

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{xlance}[]

% --- Class options / 文档类选项 ---
\newif\if@xlance@opendfm
\@xlance@opendfmfalse
\DeclareOption{opendfm}{\@xlance@opendfmtrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\PassOptionsToPackage{table,svgnames}{xcolor}
\LoadClass{article}

% =============================================================================
% Layout / 页面布局
% =============================================================================

\RequirePackage[top=3cm, bottom=3cm, left=3cm, right=3cm, columnsep=0.65cm]{geometry}
\RequirePackage{microtype}
\RequirePackage{placeins}
\RequirePackage{hyphenat}
\RequirePackage{setspace}
\RequirePackage{parskip}
\RequirePackage[latin, english]{babel}
\RequirePackage{lipsum}
\RequirePackage{etoolbox}

% =============================================================================
% Fonts (Palatino family) / 字体（Palatino 系列）
% =============================================================================

\RequirePackage[T1]{fontenc}
\RequirePackage{tgpagella}   % text / 正文字体
\RequirePackage{mathpazo}    % math & text / 数学与正文字体
\RequirePackage{inconsolata} % monospace / 等宽字体

% =============================================================================
% Math / 数学
% =============================================================================

\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{mathtools}

% =============================================================================
% Graphics / 图形
% =============================================================================

\RequirePackage{fancyhdr}
\RequirePackage{graphicx}
\RequirePackage{subcaption}
\RequirePackage{float}

% =============================================================================
% Tables / 表格
% =============================================================================

\RequirePackage{booktabs}
\RequirePackage{nicematrix}
\RequirePackage{multirow}
\RequirePackage{bm}
\newcommand{\nm}[1]{#1}

\RequirePackage{longtable}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage{adjustbox}
\RequirePackage{xspace}
\RequirePackage{enumitem}

% =============================================================================
% Table of Contents / 目录
% =============================================================================

\let\oldtableofcontents\tableofcontents
\renewcommand{\tableofcontents}{%
    \begingroup
    \setstretch{1.2}
    \oldtableofcontents
    \endgroup
}

% =============================================================================
% Color Scheme System / 配色方案系统
% =============================================================================

\RequirePackage[most]{tcolorbox}
\RequirePackage{xcolor}

% --- Public interface: register a custom color scheme / 公共接口：注册自定义配色方案 ---
% Each scheme provides 5 shades from darkest (@1) to lightest (@5).
% 每个方案提供 5 个色阶，从最深 (@1) 到最浅 (@5)。

% --- Built-in Theme A: X-LANCE (red) / 内置主题 A：X-LANCE（红色系）---
\definecolor{themeAcolor@1}{HTML}{7B1113}
\definecolor{themeAcolor@2}{HTML}{B5192C}
\definecolor{themeAcolor@3}{HTML}{D64855}
\definecolor{themeAcolor@4}{HTML}{EFA0A7}
\definecolor{themeAcolor@5}{HTML}{FDF0F1}

% --- Built-in Theme B: OpenDFM (blue-purple) / 内置主题 B：OpenDFM（蓝紫色系）---
\definecolor{themeBcolor@1}{HTML}{1A2175}
\definecolor{themeBcolor@2}{HTML}{2B37C2}
\definecolor{themeBcolor@3}{HTML}{3746F5}
\definecolor{themeBcolor@4}{HTML}{C1C5F5}
\definecolor{themeBcolor@5}{HTML}{E3E4F5}


% --- Activate default theme based on class option / 根据文档类选项激活默认主题 ---
\if@xlance@opendfm
    \colorlet{themecolor@1}{themeBcolor@1}
    \colorlet{themecolor@2}{themeBcolor@2}
    \colorlet{themecolor@3}{themeBcolor@3}
    \colorlet{themecolor@4}{themeBcolor@4}
    \colorlet{themecolor@5}{themeBcolor@5}
    \colorlet{themecolor@@1}{themeAcolor@1}
    \colorlet{themecolor@@2}{themeAcolor@2}
    \colorlet{themecolor@@3}{themeAcolor@3}
    \colorlet{themecolor@@4}{themeAcolor@4}
    \colorlet{themecolor@@5}{themeAcolor@5}
\else
    \colorlet{themecolor@1}{themeAcolor@1}
    \colorlet{themecolor@2}{themeAcolor@2}
    \colorlet{themecolor@3}{themeAcolor@3}
    \colorlet{themecolor@4}{themeAcolor@4}
    \colorlet{themecolor@5}{themeAcolor@5}
    \colorlet{themecolor@@1}{themeBcolor@1}
    \colorlet{themecolor@@2}{themeBcolor@2}
    \colorlet{themecolor@@3}{themeBcolor@3}
    \colorlet{themecolor@@4}{themeBcolor@4}
    \colorlet{themecolor@@5}{themeBcolor@5}
\fi

% --- Prompt color management / Prompt 配色管理 --------------------------------
\newcommand{\setboxscheme}[1]{
    \colorlet{boxcolor@bg}{#1@5}
    \colorlet{boxcolor@frame}{#1@3}
    \colorlet{boxcolor@text}{#1@2}

}

% Set prompt colors from initial theme / 根据初始主题设置 Prompt 颜色
\colorlet{boxcolor@bg}{themecolor@5}
\colorlet{boxcolor@frame}{themecolor@3}
\colorlet{boxcolor@text}{themecolor@2}

% --- Code listing colors (theme-independent) / 代码高亮颜色（不随主题变化）---
\definecolor{codecolor@gray}{rgb}{0.5,0.5,0.5}
\definecolor{codecolor@green}{rgb}{0,0.5,0}
\definecolor{codecolor@purple}{rgb}{0.58,0,0.82}
\definecolor{codecolor@bg}{rgb}{0.97,0.97,0.95}
\definecolor{codecolor@blue}{HTML}{1B61A7}
\definecolor{codecolor@orange}{HTML}{D75F00}
\definecolor{codecolor@red}{HTML}{C0392B}

% --- Extended user-facing colors / 扩展的用户可用颜色 ---
\definecolor{hidden-red}{RGB}{205, 44, 36}
\definecolor{hidden-blue}{RGB}{194,232,247}
\definecolor{hidden-orange}{RGB}{243,202,120}
\definecolor{hidden-green}{RGB}{34,139,34}
\definecolor{hidden-pink}{RGB}{255,245,247}
\definecolor{hidden-black}{RGB}{20,68,106}
\definecolor{purple}{RGB}{144,153,196}
\definecolor{yellow}{RGB}{255,228,123}
\definecolor{hidden-yellow}{RGB}{255,248,203}
\definecolor{tkcolor}{RGB}{224,223,255}
\definecolor{darkblue}{rgb}{0, 0.40, 0.75}



% =============================================================================
% Code Listings / 代码块
% =============================================================================

\RequirePackage{listings}

% --- Base style (shared by all listing styles) / 基础样式（所有清单共享）---
\lstdefinestyle{xlance@base}{%
    basicstyle=\ttfamily\small,
    backgroundcolor=\color{themecolor@5!50},
    frame=single,
    rulecolor=\color{themecolor@4},
    framesep=4pt,
    xleftmargin=6pt,
    xrightmargin=6pt,
    breaklines=true,
    breakatwhitespace=false,
    keepspaces=true,
    showstringspaces=false,
    showspaces=false,
    showtabs=false,
    tabsize=4,
    captionpos=b,
    numbers=left,
    numberstyle=\tiny\color{codecolor@gray},
    numbersep=8pt,
    aboveskip=1em,
    belowskip=0.8em,
}

% --- Python ---
\lstdefinestyle{python}{%
    style=xlance@base,
    language=Python,
    keywordstyle=\color{themecolor@2}\bfseries,
    keywordstyle=[2]\color{themecolor@@2},
    stringstyle=\color{themecolor@3!50!themecolor@@3},
    commentstyle=\color{themecolor@3!50!themecolor@@3}\itshape,
    morekeywords={self, True, False, None, as, with, yield, lambda, async, await},
    morekeywords=[2]{int, float, str, list, dict, tuple, set, bool, bytes, object, type},
    morestring=[b]""",
    morestring=[b]''',
    literate=%
        {→}{{\ensuremath{\rightarrow}}}1
        {←}{{\ensuremath{\leftarrow}}}1,
}

% --- JSON ---
\lstdefinestyle{json}{%
    style=xlance@base,
    string=[s]{"}{"},
    stringstyle=\color{themecolor@2},
    comment=[l]{//},
    morecomment=[s]{/*}{*/},
    commentstyle=\color{themecolor@3!50!themecolor@@3}\itshape,
    literate=%
    *{:}{{\textcolor{black}{:}}}1
        {,}{{\textcolor{black}{,}}}1
        {\{}{{\textcolor{black}{\{}}}1
        {\}}{{\textcolor{black}{\}}}}1
        {[}{{\textcolor{black}{[}}}1
        {]}{{\textcolor{black}{]}}}1
        {true}{{\textcolor{themecolor@@2}{true}}}4
        {false}{{\textcolor{themecolor@@2}{false}}}5
        {null}{{\textcolor{themecolor@@2}{null}}}4,
}

% --- Bash / Shell ---
\lstdefinestyle{bash}{%
    style=xlance@base,
    language=bash,
    keywordstyle=\color{themecolor@2}\bfseries,
    stringstyle=\color{themecolor@@2},
    commentstyle=\color{themecolor@3!50!themecolor@@3}\itshape,
    morekeywords={sudo, apt, pip, conda, git, docker, curl, wget, chmod, mkdir, cd, ls, cat, echo, export},
}

% --- Plain text / Prompt listing style / 纯文本 Prompt 清单样式 ---
\lstdefinestyle{plain}{%
    style=xlance@base,
    backgroundcolor=\color{boxcolor@bg},
    rulecolor=\color{boxcolor@frame},
    numbers=none,
    xleftmargin=6pt,
    xrightmargin=6pt,
    basicstyle=\ttfamily\small\color{boxcolor@text},
}

% =============================================================================
% Box Environments / 文本框环境
% =============================================================================

% --- Prompt tcolorbox (titled, breakable) / Prompt 彩色框（带标题，可跨页）---
\newtcolorbox{promptbox}[1][Prompt]{%
    enhanced, breakable,
    boxrule=0pt,
    colback=boxcolor@bg,
    title={#1},
    borderline west={2pt}{0pt}{boxcolor@frame},
    borderline east={2pt}{0pt}{boxcolor@frame},
}

% --- Note box (colored sidebar) / 注释框（彩色侧边栏）---
\newtcolorbox{notebox}[1][note]{%
    enhanced, breakable,
    colback=boxcolor@bg,
    colframe=boxcolor@frame,
    boxrule=0.5pt,
    arc=4pt,
    left=6pt, right=6pt,
    top=4pt, bottom=4pt,
    title={#1},
    toptitle=3pt, bottomtitle=2pt,
}


% =============================================================================
% References / 参考文献
% =============================================================================

\RequirePackage{hyperref}
\RequirePackage[noabbrev,nameinlink]{cleveref}
\hypersetup{
    colorlinks,
    linkcolor=themecolor@3,
    citecolor=themecolor@3,
    urlcolor=themecolor@3
}

\RequirePackage[square, numbers]{natbib}
\def\bibfont{\small}

% =============================================================================
% Authors, Affiliations, Metadata / 作者、机构、元数据
% =============================================================================

\renewcommand\addtolist[5][]{
    \begingroup
    \if
        \relax#3\relax\def\sep{}\else
        \def\sep{#5}
    \fi
    \let\protect\@unexpandable@protect
    \xdef#3{\expandafter{#3}\sep #4[#1]{#2}}%
    \endgroup
}

\newcommand\authorlist{}
\newcommand\authorformat[2][]{{\bfseries #2$^{#1}$}}
\renewcommand\author[2][]{\addtolist[#1]{#2}{\authorlist}{\authorformat}{, }}

\newcommand\affiliationlist{}
\newcommand\affiliationformat[2][]{{\normalsize $^{#1}$#2}}
\newcommand\affiliation[2][]{\addtolist[#1]{#2}{\affiliationlist}{\affiliationformat}{, }}

\newcommand\contributionlist{}
\newcommand\contributionformat[2][]{{\normalsize $^{#1}$#2}}
\newcommand\contribution[2][]{\addtolist[#1]{#2}{\contributionlist}{\contributionformat}{, }}

\newcommand\metadatalist{}
\newcommand\metadataformat[2][]{{\small {\bfseries #1:} #2}}
\newcommand\metadata[2][]{\addtolist[#1]{#2}{\metadatalist}{\metadataformat}{\par}}

\newcommand\metadataformatinfo[2][]{{\small #2}}
\newcommand\metadatainfo[1]{\addtolist{#1}{\metadatalist}{\metadataformatinfo}{}}

\renewcommand{\abstract}[1]{\def\abstractlist{{\color{themecolor@2} #1}}}
\newcommand{\email}[1]{\href{mailto:#1}{\texttt{#1}}}

\renewcommand\date[1]{\metadata[Date]{#1}}

% =============================================================================
% Equal Contribution & Corresponding Author / 同等贡献与通讯作者
% =============================================================================

% \equalcontribution and \correspondence are used inside \author to mark
% contributors.  They are defined with \protected\def so they survive the
% \xdef expansion in \addtolist and only execute at typesetting time.
% \equalcontribution 和 \correspondence 用于 \author 内部标记贡献者。
% 使用 \protected\def 定义，以便在 \addtolist 的 \xdef 展开中保留，
% 仅在排版时执行。

\newif\if@xlance@equalcontrib
\@xlance@equalcontribfalse

\protected\def\equalcontribution#1{%
    \global\@xlance@equalcontribtrue
    #1\textsuperscript{*}%
}

\newif\if@xlance@corresponding
\@xlance@correspondingfalse
\newcommand{\@xlance@corr@email}{}

% Usage / 用法: \correspondence{email}{Author Name}
\protected\def\correspondence#1#2{%
    \global\@xlance@correspondingtrue
    \gdef\@xlance@corr@email{#1}%
    #2\textsuperscript{\dag}%
}

% =============================================================================
% Title / 标题
% =============================================================================

\renewcommand{\title}[1]{%
    \gdef\@title{#1}%                       % store for fancyhdr / 供 fancyhdr 使用
    \gdef\titlelist{{\Large\bfseries #1}}%   % store for title-box / 供标题框使用
}

% =============================================================================
% Appendix / 附录
% =============================================================================

\let\xlance@origappendix\appendix
\renewcommand{\appendix}{%
    \xlance@origappendix
    \begin{center}
        {\LARGE\bfseries Appendix}
    \end{center}
    \vspace{1em}
}

% =============================================================================
% Publish & Revise Dates / 发布与修订日期
% =============================================================================

\newcommand\@xlance@publishdate{}
\newcommand{\publishdate}[1]{\gdef\@xlance@publishdate{#1}}

\newcommand\@xlance@revdates{}
\newcommand{\revisedate}[1]{%
    \ifdefempty{\@xlance@revdates}%
    {\gdef\@xlance@revdates{#1}}%
    {\g@addto@macro\@xlance@revdates{, #1}}%
}

% =============================================================================
% Title Box / 标题框
% =============================================================================

\newlength{\xlance@headerlogoheight}
\setlength{\xlance@headerlogoheight}{1.0cm}

\newcommand{\mymaketitle}{%
    \tcbset{enhanced}
    \tcbset{colframe=themecolor@2!25}
    \tcbset{boxrule=1pt}
    \tcbset{left=0.5cm}
    \tcbset{right=0.5cm}
    \tcbset{top=0.5cm}
    \tcbset{bottom=0.5cm}
    \tcbset{arc=10pt}
    \tcbset{colback=themecolor@5!40}
    \tcbset{before skip=0pt}
    \tcbset{grow to left by=1.5pt}
    \tcbset{grow to right by=1.5pt}
    \begin{tcolorbox}
    \setlength{\parindent}{0cm}
    \setlength{\parskip}{0.5cm}
    {
        \setlength{\parskip}{0cm}
        \raggedright
        \nohyphens
        %
        {
            \setstretch{1.618}
            \titlelist\par
        }
        \vskip 0.2cm
        %
        \authorlist\par
        \vskip 0.2cm
        %
        \affiliationlist\par
        %
        \begin{center}\contributionlist\end{center}
        %
        {\small
        \if@xlance@equalcontrib\textsuperscript{*}Equal Contribution\fi
            \if@xlance@corresponding
            \if@xlance@equalcontrib\hspace{1em}\fi
            \textsuperscript{\dag}Correspondence to: \texttt{\@xlance@corr@email}%
            \fi
            \par}
    }
    %
    \abstractlist
    %
    \vskip 0.5cm
    %
    {
        \setlength{\parskip}{0cm}
        \ifdefempty{\metadatalist}{\vspace*{0.65cm}}{\metadatalist\par}
    }
    %
    \vskip 0.3cm
    {\small\color{themecolor@2}%
    \setlength{\parskip}{0.05cm}%
    \ifdefempty{\@xlance@publishdate}{}{%
        \textbf{Publish Date:} \@xlance@publishdate
    }%
    \ifdefempty{\@xlance@revdates}{}{%
        \ifdefempty{\@xlance@publishdate}{}{\par}%
        \textbf{Revise Date:} \@xlance@revdates
    }%
    }
    \end{tcolorbox}
    \tcbset{reset}
    \FloatBarrier
}

\if@twocolumn%
\renewcommand{\maketitle}{
    \twocolumn[%
        \mymaketitle
        \vskip 0.38cm
    ]
}%
\else%
\renewcommand{\maketitle}{
    \mymaketitle
}%
\fi

% =============================================================================
% Page Styles / 页面样式
% =============================================================================

% --- First page: logos in header, page number at bottom center ---
% --- 首页：页眉显示 logo，页码居底部中央 ---
\fancypagestyle{firstpage}{%
    \fancyhf{}%
    \if@xlance@opendfm
        \fancyhead[L]{%
            \includegraphics[height=\xlance@headerlogoheight]{xlance/assets/logos/XLANCE.png}%
            \hspace{0.4cm}%
            \includegraphics[height=\xlance@headerlogoheight]{xlance/assets/logos/SII.png}%
            \hspace{0.4cm}%
            \includegraphics[height=\xlance@headerlogoheight]{xlance/assets/logos/SZLab.png}%
        }%
        \fancyhead[R]{%
            \includegraphics[height=\xlance@headerlogoheight, trim=30 30 30 30, clip]{xlance/assets/logos/OpenDFM.png}%
        }%
    \else
        \fancyhead[L]{%
            \includegraphics[height=\xlance@headerlogoheight]{xlance/assets/logos/XLANCE_full.png}%
        }%
    \fi
    \fancyfoot[C]{\thepage}%
    \renewcommand{\headrulewidth}{0.4pt}%
}

% --- Body pages: title in header ---
% --- 正文页：页眉显示标题 ---
\fancypagestyle{body}{%
    \fancyhf{}%
    \fancyfoot[C]{\thepage}%
    \renewcommand{\headrulewidth}{0.4pt}%
}

% --- Override \maketitle to set page styles ---
% --- 重写 \maketitle 以设置页面样式 ---
\let\oldmaketitle\maketitle
\renewcommand{\maketitle}{%
    \begingroup
    \oldmaketitle
    \thispagestyle{firstpage}
    \endgroup
    %
    \pagestyle{body}
    \fancyhead[L]{\nouppercase{\@title}}% left header shows title / 页眉左侧显示标题
}

% --- Plain style (used by chapter/section breaks in twocolumn) ---
% --- Plain 样式（双栏模式下章节分页时使用）---
\fancypagestyle{plain}{%
    \fancyhf{}%
    \fancyfoot[C]{\thepage}%
    \renewcommand{\headrulewidth}{0pt}%
}

% =============================================================================
% Figure Placeholder / 图片占位符
% =============================================================================

% Usage / 用法: \placeholder[width]{height} — default width is \linewidth / 默认宽度为 \linewidth
\RequirePackage{tikz}
\newcommand{\placeholder}[2][\linewidth]{%
    \begin{tikzpicture}
    \node[
        draw=gray!50,
        fill=gray!8,
        line width=0.6pt,
        minimum width=#1,
        minimum height=#2,
        inner sep=0pt
    ] (box) {};
    \draw[gray!40, line width=0.5pt] (box.north west) -- (box.south east);
    \draw[gray!40, line width=0.5pt] (box.north east) -- (box.south west);
    \node[gray, font=\small\itshape] at (box.center) {Figure};
    \end{tikzpicture}%
}

% =============================================================================
% Convenience Commands / 便捷命令
% =============================================================================

\newcommand{\eg}{\textit{e.g.,~}}
\newcommand{\ie}{\textit{i.e.,~}}
\newcommand{\github}{\raisebox{-1.5pt}[0pt][0pt]{\includegraphics[height=1.0em]{xlance/assets/logos/GitHub.png}}\xspace}
\newcommand{\huggingface}{\raisebox{-1.5pt}[0pt][0pt]{\includegraphics[height=1.0em]{xlance/assets/logos/HuggingFace.png}}\xspace}
\newcommand{\web}{\raisebox{-1.5pt}[0pt][0pt]{\includegraphics[height=1.0em]{xlance/assets/logos/Website.png}}\xspace}

% =============================================================================
% Global Layout Tweaks / 全局排版微调
% =============================================================================

\hbadness=10000
\vbadness=10000
\hfuzz=5pt
\setlength{\emergencystretch}{3em}
\hfuzz=2pt
\setlength{\headheight}{34pt}
\allowdisplaybreaks

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This style template is modified from "A new style for FAIR pre-prints"
% Original Author: dlp@meta.com
% Original Version: 1.1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
