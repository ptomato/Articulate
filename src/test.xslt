<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
  <document>
    <head>
      <title><xsl:value-of select="html/body/h1[1]/span"/></title>
      <authors><xsl:value-of select="html/body/p[1]/span"/></authors>
    </head>
    <body>
      <xsl:for-each select="html/body/h2/span">
        <section><xsl:value-of select="."/></section>
      </xsl:for-each>
      <xsl:for-each select="html/body/p">
        <xsl:if test="not(position()=1)">
          <xsl:if test="span != ''">
            <p><xsl:value-of select="normalize-space(span)"/></p>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </body>
  </document>
</xsl:template>

</xsl:stylesheet>
