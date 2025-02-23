<?xml version="1.0" encoding="UTF-8"?>
<!--
 * SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
 * SPDX-License-Identifier: MIT
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" omit-xml-declaration="yes"/>
  <xsl:template match="/"><xsl:text disable-output-escaping="yes">{</xsl:text><xsl:apply-templates select="puzzles"/>
    "puzzles": [
    <xsl:apply-templates select="puzzles/puzzle"/>
    <xsl:text disable-output-escaping="yes">
  ]
}</xsl:text>
  </xsl:template>
  <xsl:template match="puzzles">
    <xsl:text>
    "version": "</xsl:text>
    <xsl:value-of select="@version"/>
    <xsl:text>",</xsl:text>
    <xsl:text>
    "date": "</xsl:text>
    <xsl:value-of select="@date"/>
    <xsl:text>", </xsl:text>
  </xsl:template>
  <xsl:template match="puzzle">
    <xsl:text disable-output-escaping="no">{</xsl:text>
    <xsl:text>
      "id": "</xsl:text>
    <xsl:value-of select="id"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "ticket": "</xsl:text>
    <xsl:value-of select="ticket"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "file": "</xsl:text>
    <xsl:value-of select="file"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "lines": "</xsl:text>
    <xsl:value-of select="lines"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "body": "</xsl:text>
    <xsl:value-of select="translate(body, '&quot;', '&#x201C;')"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "estimate": "</xsl:text>
    <xsl:value-of select="estimate"/>
    <xsl:text>", </xsl:text>
    <xsl:text>
      "role": "</xsl:text>
    <xsl:value-of select="role"/>
    <xsl:text>"</xsl:text>
    <xsl:text disable-output-escaping="yes">
    }</xsl:text>
    <xsl:if test="position() != last()">,
  </xsl:if>
  </xsl:template>
</xsl:stylesheet>
