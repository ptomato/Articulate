<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	extension-element-prefixes="str">

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:template match="/">
  <document>
    <xsl:apply-templates mode="preamble" select="/html/body"/>
  </document>
</xsl:template>

<xsl:template mode="preamble" match="/html/body">
  <preamble>
    <title><xsl:value-of select="h1[1]"/></title>
    <authors>
      <xsl:for-each select="str:tokenize(string(p[1]), ',')">
        <author>
          <xsl:value-of select="normalize-space(.)"/>
        </author>
      </xsl:for-each>
    </authors>
  </preamble>
  <body>
    <xsl:apply-templates mode="body" select="/html/body"/>
  </body>
</xsl:template>

<xsl:template mode="body" match="/html/body">
  <xsl:for-each select="h2">
    <xsl:variable name="header" select="."/>
    <xsl:variable name="section-type">
      <xsl:choose>
        <xsl:when test="span='Abstract'">abstract</xsl:when>
        <xsl:when test="span='References' or span='Bibliography'">bibliography</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$section-type}">
      <xsl:if test="$section-type='section'">
        <title><xsl:value-of select="span"/></title>
      </xsl:if>
      <xsl:for-each select="following-sibling::p[preceding-sibling::h2[1] = $header]">
	    <xsl:if test="span != ''">
	      <xsl:variable name="trim-content" select="normalize-space(span)"/>
	      <xsl:choose>
	        <xsl:when test="$section-type='bibliography' and starts-with($trim-content,'[')">
	          <item>
	            <citekey><xsl:value-of select="substring-after(substring-before($trim-content,']'),'[')"/></citekey>
	            <p><xsl:value-of select="normalize-space(substring-after($trim-content,']'))"/></p>
	          </item>
	        </xsl:when>
	        <xsl:otherwise>
	          <xsl:call-template name="paragraph">
	            <xsl:with-param name="text" select="$trim-content"/>
	          </xsl:call-template>
	        </xsl:otherwise>
	      </xsl:choose>
	    </xsl:if>
      </xsl:for-each>
    </xsl:element>
  </xsl:for-each>
</xsl:template>

<!-- Finds out the type of paragraph: regular, figure, display math, etc.-->
<xsl:template name="paragraph">
  <xsl:param name="text"/>
  <xsl:choose>
    <!-- #Figure is a figure -->
    <xsl:when test="starts-with($text,'#Figure')">
      <figure>
        <label><xsl:call-template name="label-name">
          <xsl:with-param name="text" select="normalize-space(substring-after(substring-before($text,'.'),'#Figure'))"/>
        </xsl:call-template></label>
        <caption>
          <xsl:call-template name="text">
            <xsl:with-param name="text" select="normalize-space(substring-after($text,'.'))"/>
          </xsl:call-template>
        </caption>
      </figure>
    </xsl:when>
    <!-- #Equation is display math -->
    <xsl:when test="starts-with($text,'#Equation')">
      <displaymath>
        <label><xsl:call-template name="label-name">
          <xsl:with-param name="text" select="normalize-space(substring-after(substring-before($text,'.'),'#Equation'))"/>
        </xsl:call-template></label>
        <math>
          <xsl:call-template name="text">
            <xsl:with-param name="text" select="normalize-space(substring-after($text,'.'))"/><!-- FIXME -->
          </xsl:call-template>
        </math>
      </displaymath>
    </xsl:when>
    <!-- Anything else is a regular paragraph -->
    <xsl:otherwise>
      <p><xsl:apply-templates/></p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:variable name="italic-class">c1</xsl:variable>
<xsl:variable name="subscript-class">c3</xsl:variable>

<xsl:template match="span[contains(@class,'c1') and preceding-sibling::span[1][not(contains(@class,'c1'))]]">
  <math><xsl:value-of select="text()"/>
    <xsl:call-template name="continue-math">
      <xsl:with-param name="next" select="following-sibling::span[1]"/>
    </xsl:call-template>
  </math>
</xsl:template>

<xsl:template name="continue-math">
  <xsl:param name="next"/>
  <xsl:choose>
    <xsl:when test="$next[contains(@class,'c1')]">
      <xsl:choose>
        <xsl:when test="$next[contains(@class,'c3')]">
          <sub><xsl:value-of select="$next/text()"/></sub>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$next/text()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="continue-math">
        <xsl:with-param name="next" select="$next/following-sibling::span[1]"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise/> <!-- Do nothing -->
  </xsl:choose>
</xsl:template>

<!-- Don't process math elements that are preceded by another math element -->
<xsl:template match="span[contains(@class,'c1') and preceding-sibling::span[1][contains(@class,'c1')]]"/> <!-- Do nothing -->

<xsl:template match="span">
  <xsl:call-template name="text">
    <xsl:with-param name="text" select="text()"/>
  </xsl:call-template>
</xsl:template>

<!-- Processes paragraph-level text -->
<xsl:template name="text">
  <xsl:param name="text"/>
  <xsl:choose>
    <!-- [Author2012] => <cite>Author2012</cite> -->
    <xsl:when test="contains($text,'[') and contains(substring-after($text,'['),']')">
      <xsl:call-template name="text">
        <xsl:with-param name="text" select="substring-before($text,'[')"/>
      </xsl:call-template>
      <cite><xsl:value-of select="substring-after(substring-before($text,']'),'[')"/></cite>
      <xsl:call-template name="text">
        <xsl:with-param name="text" select="substring-after($text,']')"/>
      </xsl:call-template>
    </xsl:when>
    <!-- regular text -->
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Makes a figure or equation label out of text -->
<xsl:template name="label-name">
  <xsl:param name="text"/>
  <!-- To compensate for XPath 1.0's lack of a lowercasing function -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:value-of select="translate(translate($text,$uc,$lc),' ','-')"/>
</xsl:template>

</xsl:stylesheet>
