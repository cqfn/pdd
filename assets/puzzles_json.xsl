<?xml version="1.0"?>
<!--
(The MIT License)

Copyright (c) 2014-2025 Yegor Bugayenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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
