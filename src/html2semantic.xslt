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
	          <p><xsl:value-of select="$trim-content"/></p>
	        </xsl:otherwise>
	      </xsl:choose>
	    </xsl:if>
      </xsl:for-each>
    </xsl:element>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
