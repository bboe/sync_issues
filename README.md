# Sync Issues for GitHub

sync_issues is a ruby gem to that allows the easy creation and synchronization
of issues on GitHub with structured local data.


## Installation

To install sync_issues run:

    gem install sync_issues

## Running sync_issues

Run sync_issues via:

    sync_tasks /path/to/tasks/directory bboe/repo1 appfolio/repo2


## Local Issue Directory

Locally you will want to have a directory of markdown files each of which will
represent a single issue on GitHub. When syncing new issues will be created
according to lexicographic filename order if an issue doesn't already exist
with a matching title as specified in the file's frontmatter. Existing issues
will be updated if necessary.

## Issue File

Each issue file is a markdown file with a `yaml` frontmatter (a format used by
[jeykll](http://jekyllrb.com/docs/frontmatter/)).

### Task Frontmatter

The frontmatter of an issue file can contain the following attributes:

* __title__: (required) Used as the title of the issue on GitHub. The title is
  used as the unique key when syncing updated tasks with existing issues.
* __assignee__: (optional) Assign or reassign the issue to the github username
  specified. Existing assignee will not be removed on sync if the field is not
  provided.
* __label__: (optional) Set the labels of the issue to this comma-separated
  string of issues. Existing labels will not be cleared on sync when the field
  is not provided.
