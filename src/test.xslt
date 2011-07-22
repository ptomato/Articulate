<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
	<title><xsl:value-of select="html/body/h1/span"/></title>
</xsl:template>

</xsl:stylesheet>
