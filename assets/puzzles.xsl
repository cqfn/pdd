<?xml version="1.0" encoding="UTF-8"?>
<!--
 * SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
 * SPDX-License-Identifier: MIT
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="description" content="PDD puzzles"/>
        <meta name="keywords" content="puzzle driven development"/>
        <meta name="author" content="teamed.io"/>
        <title>
          <xsl:text>PDD Summary Report</xsl:text>
        </title>
        <style type="text/css">
          body {
          background-color: #e6e1ce;
          font-family: Arial, sans-serif;
          margin: 2em;
          font-size: 22px;
          }
          table {
          border-spacing: 0px;
          border-collapse: collapse;
          }
          th, td {
          vertical-align: top;
          padding: 1em;
          border: 1px solid gray;
          }
          th {
          text-align: left;
          }
        </style>
      </head>
      <body>
        <div>
          <h1>PDD Summary</h1>
          <table>
            <colgroup>
              <col/>
              <col/>
              <col/>
              <col/>
              <col/>
              <col style="width:7em;"/>
              <col/>
            </colgroup>
            <thead>
              <tr>
                <th>
                  <xsl:text>id</xsl:text>
                </th>
                <th>
                  <xsl:text>ticket</xsl:text>
                </th>
                <th>
                  <xsl:text>body</xsl:text>
                </th>
                <th>
                  <xsl:text>estimate</xsl:text>
                </th>
                <th>
                  <xsl:text>role</xsl:text>
                </th>
              </tr>
            </thead>
            <tbody>
              <xsl:apply-templates select="puzzles/puzzle"/>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="puzzle">
    <tr>
      <td>
        <xsl:value-of select="id"/>
      </td>
      <td>
        <xsl:value-of select="ticket"/>
      </td>
      <td>
        <code>
          <xsl:value-of select="file"/>
          <xsl:text>:</xsl:text>
          <xsl:value-of select="lines"/>
        </code>
        <br/>
        <xsl:value-of select="body"/>
      </td>
      <td>
        <xsl:value-of select="estimate"/>
      </td>
      <td>
        <xsl:value-of select="role"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
