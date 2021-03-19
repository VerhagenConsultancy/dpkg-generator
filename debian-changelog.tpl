% for version in data["versions"]:
<%
_version = version["tag"] + "-1" if version["tag"] else opts["unreleased_version_label"]
title = "%s (%s) %s; urgency=%s" % ('@PACKAGE@', _version, '@DISTRIBUTION@', 'low')

nb_sections = len(version["sections"])
%>${title}

% for section in version["sections"]:
% for commit in section["commits"]:
<%
subject = "%s [%s]" % (commit["subject"], ", ".join(commit["authors"]))
entry = indent(indent('\n'.join(textwrap.wrap(subject)),
                       first="* ").rstrip())
%>${entry}
% if commit["body"]:
${indent(commit["body"])}
% endif
% endfor
% endfor
<%! import datetime %>
<%
_date = datetime.datetime.strptime(version["date"], '%Y-%m-%d').strftime('%a, %d %b %Y %H:%M:%S +0000')
%> -- @MAINTAINER@ <@MAINTAINER_EMAIL@>  ${_date}

% endfor
