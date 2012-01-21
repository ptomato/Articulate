<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" indent="no"/>
<xsl:strip-space elements="*"/>

<xsl:template match="/">
  <xsl:text>\documentclass[a4paper]{article}

\newcommand{\unit}[1]{\mbox{$\;\mathrm{#1}$}}
\newcommand{\micro}{\mbox{\textmu}}

\begin{document}

</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{document}
</xsl:text>
</xsl:template>

<xsl:template match="/document/preamble">
  <xsl:apply-templates select="title"/>
  <xsl:apply-templates select="authors"/>
  <xsl:text>\date{}
\maketitle

</xsl:text>
</xsl:template>

<xsl:template match="/document/preamble/title">
  <xsl:text>\title{</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="/document/preamble/authors">
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
  <xsl:apply-templates select="abstract|section|p"/>
</xsl:template>

<xsl:template match="/document/body/abstract">
  <xsl:text>\begin{abstract}
</xsl:text>
  <xsl:apply-templates select="p"/>
  <xsl:text>\end{abstract}

</xsl:text>
</xsl:template>

<xsl:template match="/document/body/section">
  <xsl:text>\section{</xsl:text>
  <xsl:value-of select="./title"/>
  <xsl:text>}

</xsl:text>
  <xsl:apply-templates select="p|figure|displaymath"/>
</xsl:template>

<xsl:template match="p">
  <xsl:apply-templates mode="inline"/>
  <!--Add a newline-->
  <xsl:text>
</xsl:text>
  <!--Add an extra newline if there is another paragraph following this one-->
  <xsl:if test="following-sibling::p">
    <xsl:text>
</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="figure">
  <xsl:text>\begin{figure}
  \caption{</xsl:text>
  <xsl:value-of select="caption"/>
  <xsl:text>}
  \label{</xsl:text>
  <xsl:value-of select="label"/>
  <xsl:text>}
\end{figure}

</xsl:text>
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

</xsl:stylesheet>
