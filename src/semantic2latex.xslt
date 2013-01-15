<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="document-options">a4paper</xsl:param>
<xsl:param name="packages"/>
<xsl:param name="preamble-commands"/>
<xsl:param name="graph-width">3.25in</xsl:param>

<xsl:output method="text" indent="no"/>
<xsl:strip-space elements="*"/>

<xsl:template match="/">
  <xsl:text>\documentclass[</xsl:text>
  <xsl:value-of select="$document-options"/>
  <xsl:text>]{article}
\usepackage{textcomp}
\usepackage{graphicx}
</xsl:text>
  <xsl:value-of select="$packages"/>
  <xsl:text>
\newcommand{\unit}[1]{\mbox{$\;\mathrm{#1}$}}
\newcommand{\micro}{\mbox{\textmu}}
\newlength\graphwidth
\setlength\graphwidth{</xsl:text>
  <xsl:value-of select="$graph-width"/>
  <xsl:text>}
</xsl:text>
  <xsl:value-of select="$preamble-commands"/>
  <xsl:apply-templates select="/document/preamble"/>
<xsl:text>
\begin{document}

</xsl:text>
  <xsl:apply-templates select="/document/head"/>
  <xsl:apply-templates select="/document/body"/>
  <xsl:text>\end{document}
</xsl:text>
</xsl:template>

<xsl:template match="/document/preamble/command">
  <xsl:text>\newcommand{\</xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:text>}</xsl:text>
  <xsl:if test="@args">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@args"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="/document/head">
  <xsl:apply-templates/>
  <xsl:text>\date{}
\maketitle

</xsl:text>
</xsl:template>

<xsl:template match="/document/head/title">
  <xsl:text>\title{</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="/document/head/authors">
  <xsl:text>\author{</xsl:text>
  <xsl:for-each select="author">
    <xsl:value-of select="translate(., ' ', '~')"/>
    <xsl:if test="position() != last()">
      <xsl:text> \and </xsl:text>
    </xsl:if>
  </xsl:for-each>
  <xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="/document/body">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document/body/abstract">
  <xsl:text>\begin{abstract}
</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{abstract}

</xsl:text>
</xsl:template>

<xsl:template match="/document/body/section">
  <xsl:if test="@title">
    <xsl:text>\section</xsl:text>
    <xsl:if test="@nonumber"><xsl:text>*</xsl:text></xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:value-of select="@title"/>
    <xsl:text>}

</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document/body/bibliography">
  <xsl:text>
\begin{thebibliography}{99}

</xsl:text>
  <xsl:for-each select="item">
    <xsl:text>\bibitem{</xsl:text>
    <xsl:value-of select="citekey"/>
    <xsl:text>} </xsl:text>
    <xsl:value-of select="p"/>
    <xsl:text>

</xsl:text>
  </xsl:for-each>
  <xsl:text>\end{thebibliography}
</xsl:text>
</xsl:template>

<xsl:template match="p">
  <xsl:apply-templates mode="inline"/>
  <!--Add a newline-->
  <xsl:text>
</xsl:text>
  <!--Add an extra newline if there is another paragraph following this one-->
  <xsl:if test="following-sibling::p or following-sibling::displaymath">
    <xsl:text>
</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="figure">
  <xsl:text>\begin{figure}
  \centering
</xsl:text>
  <xsl:if test="image">
    <xsl:text>  \includegraphics[width=\graphwidth]{</xsl:text>
    <xsl:value-of select="image/attribute::uri"/>
    <xsl:text>}
</xsl:text>
  </xsl:if>
  <xsl:text>  \caption{</xsl:text>
  <xsl:apply-templates mode="inline" select="caption"/>
  <xsl:text>}
  \label{</xsl:text>
  <xsl:value-of select="label"/>
  <xsl:text>}
\end{figure}

</xsl:text>
</xsl:template>

<xsl:template match="tablefloat">
  <xsl:text>\begin{table}
  \centering
</xsl:text>
  <xsl:apply-templates select="table"/>
  <xsl:text>  \label{</xsl:text>
  <xsl:value-of select="label"/>
  <xsl:text>}
\end{table}

</xsl:text>
</xsl:template> <!-- tablefloat -->

<xsl:template match="table">
  <xsl:text>  \begin{tabular}{</xsl:text>
  <xsl:call-template name="repeat-string">
    <xsl:with-param name="string" select="'l'"/>
    <xsl:with-param name="times" select="@columns"/>
  </xsl:call-template>
  <xsl:text>}
</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>  \end{tabular}
</xsl:text>
</xsl:template>

<xsl:template match="row">
  <xsl:apply-templates/>
  <xsl:text>\\
</xsl:text>
</xsl:template>

<xsl:template match="cell">
  <xsl:text>    </xsl:text>
  <xsl:apply-templates mode="inline"/>
  <xsl:text> &amp; </xsl:text>
</xsl:template>

<xsl:template match="displaymath">
  <xsl:text>\begin{equation}\label{</xsl:text>
  <xsl:value-of select="label"/>
  <xsl:text>}
</xsl:text>
  <xsl:apply-templates mode="math" select="math"/>
  <xsl:text>
\end{equation}

</xsl:text>
</xsl:template>

<!-- Templates for inline mode -->

<xsl:template mode="inline" match="cite">
  <xsl:text>\cite{</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="inline" match="math">
  <xsl:text>$</xsl:text>
  <xsl:apply-templates mode="math"/>
  <xsl:text>$</xsl:text>
</xsl:template>

<xsl:template mode="inline" match="ref">
  <xsl:text>\ref{</xsl:text>
  <xsl:value-of select="@label"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="inline" match="emphasis">
  <xsl:text>\emph{</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="inline" match="footnote">
  <xsl:text>\footnote{</xsl:text>
  <xsl:apply-templates mode="inline"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="inline" match="comment">
  <xsl:text>\marginpar{</xsl:text>
  <xsl:apply-templates mode="inline"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- Templates for math mode -->

<xsl:template mode="math" match="sup">
  <xsl:text>^{</xsl:text>
  <xsl:apply-templates mode="math"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="math" match="sub">
  <xsl:text>_{</xsl:text>
  <xsl:apply-templates mode="math"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template mode="math" match="unit">
  <xsl:text>\unit{</xsl:text>
  <xsl:apply-templates mode="math"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- Helper templates -->

<!-- http://stackoverflow.com/questions/3228270/transform-an-integer-value-to-a-repeated-character -->
<xsl:template name="repeat-string">
  <xsl:param name="string" select="''"/>
  <xsl:param name="times" select="1"/>

  <xsl:if test="number($times) &gt; 0">
    <xsl:value-of select="$string"/>
    <xsl:call-template name="repeat-string">
      <xsl:with-param name="string" select="$string"/>
      <xsl:with-param name="times" select="$times - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
