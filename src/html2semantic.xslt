<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	extension-element-prefixes="str">

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<!-- These parameters have to be found out by peeking in the CSS?
Or is there a way to do it from within the XSLT code? -->
<xsl:param name="italic-class">c1</xsl:param>
<xsl:param name="subscript-class">c2</xsl:param>
<xsl:param name="superscript-class">c3</xsl:param>

<xsl:template match="/">
  <document>
    <xsl:apply-templates mode="preamble" select="/html/body"/>
  </document>
</xsl:template>

<xsl:template mode="preamble" match="/html/body">
  <preamble>
      <xsl:apply-templates mode="definitions" select="/html/body/p[preceding-sibling::h1[1]/span = 'Latex Code']"/>
  </preamble>
  <head>
    <title><xsl:value-of select="p[contains(@class,'title')]"/></title>
    <authors>
      <xsl:for-each select="str:tokenize(string(p[contains(@class,'subtitle')]), ',')">
        <author>
          <xsl:value-of select="normalize-space(.)"/>
        </author>
      </xsl:for-each>
    </authors>
  </head>
  <body>
    <xsl:apply-templates mode="body" select="/html/body"/>
  </body>
</xsl:template>

<xsl:template mode="definitions" match="p">
  <xsl:choose>
    <xsl:when test="starts-with(span,'#define')">
      <command>
        <xsl:variable name="name-and-args">
          <xsl:value-of select="normalize-space(substring-before(substring-after(span,'#define '),' '))"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($name-and-args,'[')">
            <xsl:attribute name="name">
              <xsl:value-of select="substring-before($name-and-args,'[')"/>
            </xsl:attribute>
            <xsl:attribute name="args">
              <xsl:value-of select="substring-before(substring-after($name-and-args,'['),']')"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="name">
              <xsl:value-of select="$name-and-args"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="normalize-space(substring-after(substring-after(span,'#define '),' '))"/>
      </command>
    </xsl:when>
    <xsl:when test="starts-with(span,'#package')">
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template mode="body" match="/html/body">
  <xsl:for-each select="h1">
    <xsl:variable name="header" select="."/>
    <xsl:variable name="section-type">
      <xsl:choose>
        <xsl:when test="span='Abstract'">abstract</xsl:when>
        <xsl:when test="span='References' or span='Bibliography'">bibliography</xsl:when>
        <xsl:when test="span='Latex Code'">definitions</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$section-type != 'definitions'">
      <xsl:element name="{$section-type}">
        <xsl:if test="$section-type='section'">
          <title><xsl:value-of select="span"/></title>
        </xsl:if>
        <xsl:for-each select="following-sibling::p[preceding-sibling::h1[1] = $header]">
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
    </xsl:if>
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
        <xsl:choose>
          <xsl:when test="normalize-space(substring-after($text,'.')) != ''">
            <caption>
              <xsl:call-template name="text">
                <xsl:with-param name="text" select="normalize-space(substring-after($text,'.'))"/>
              </xsl:call-template>
            </caption>
          </xsl:when>
          <xsl:when test="child::span[1]/following-sibling::img[1]">
            <image>
              <xsl:attribute name="uri">
                <xsl:value-of select="child::span[1]/following-sibling::img[1]/attribute::src"/>
              </xsl:attribute>
            </image>
            <caption>
              <xsl:apply-templates mode="paragraph" select="child::img/following-sibling::span"/>
            </caption>
          </xsl:when>
          <xsl:otherwise/> <!-- No caption -->
        </xsl:choose>
      </figure>
    </xsl:when>
    <!-- #Equation is display math -->
    <xsl:when test="starts-with($text,'#Equation')">
      <displaymath>
        <label><xsl:call-template name="label-name">
          <xsl:with-param name="text" select="normalize-space(substring-after(substring-before($text,'.'),'#Equation'))"/>
        </xsl:call-template></label>
        <math>
          <xsl:value-of select="normalize-space(substring-after($text,'.'))"/>
          <xsl:apply-templates mode="math" select="child::span[position() != 1]"/>
        </math>
      </displaymath>
    </xsl:when>
    <!-- Anything else is a regular paragraph -->
    <xsl:otherwise>
      <p><xsl:apply-templates mode="paragraph"/></p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Match references -->
<xsl:template mode="paragraph" match="span[child::a]">
  <ref>
    <xsl:attribute name="label">
      <xsl:call-template name="label-name">
        <xsl:with-param name="text" select="a/text()"/>
      </xsl:call-template>
    </xsl:attribute>
  </ref>
</xsl:template>

<xsl:template mode="paragraph" match="span">
  <!-- Only process math elements that are not preceded by another math element -->
  <xsl:choose>
    <xsl:when test="contains(@class,$italic-class)">
      <xsl:if test="preceding-sibling::span[1][not(contains(@class,$italic-class))]">
        <math><xsl:value-of select="text()"/>
          <xsl:call-template name="continue-math">
            <xsl:with-param name="next" select="following-sibling::span[1]"/>
          </xsl:call-template>
        </math>
      </xsl:if>
    </xsl:when>
    <!-- Not a math element -->
    <xsl:otherwise>
      <xsl:call-template name="text">
        <xsl:with-param name="text" select="text()"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="continue-math">
  <xsl:param name="next"/>
  <xsl:choose>
    <xsl:when test="$next[contains(@class,$italic-class)]">
      <xsl:apply-templates mode="math" select="$next"/>
      <xsl:call-template name="continue-math">
        <xsl:with-param name="next" select="$next/following-sibling::span[1]"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise/> <!-- Do nothing -->
  </xsl:choose>
</xsl:template>

<!-- XSLT 1.0 doesn't allow parameters in match expressions, annoying -->
<xsl:template mode="math" match="span">
  <xsl:choose>
    <xsl:when test="contains(@class,$subscript-class)">
      <sub><xsl:value-of select="text()"/></sub>
    </xsl:when>
    <xsl:when test="contains(@class,$superscript-class)">
      <sup><xsl:value-of select="text()"/></sup>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="text()"/>
    </xsl:otherwise>
  </xsl:choose>
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
