<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#yarn_audit_test"></a>

## yarn_audit_test

<pre>
yarn_audit_test(<a href="#yarn_audit_test-name">name</a>, <a href="#yarn_audit_test-lock">lock</a>, <a href="#yarn_audit_test-manifest">manifest</a>)
</pre>

**ATTRIBUTES**

| Name                                          | Description                    | Type                                                               | Mandatory | Default |
| :-------------------------------------------- | :----------------------------- | :----------------------------------------------------------------- | :-------- | :------ |
| <a id="yarn_audit_test-name"></a>name         | A unique name for this target. | <a href="https://bazel.build/docs/build-ref.html#name">Name</a>    | required  |         |
| <a id="yarn_audit_test-lock"></a>lock         | -                              | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required  |         |
| <a id="yarn_audit_test-manifest"></a>manifest | -                              | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional  | None    |

<a id="#yarn_resolve"></a>

## yarn_resolve

<pre>
yarn_resolve(<a href="#yarn_resolve-name">name</a>, <a href="#yarn_resolve-output">output</a>, <a href="#yarn_resolve-path">path</a>, <a href="#yarn_resolve-refresh">refresh</a>)
</pre>

**ATTRIBUTES**

| Name                                     | Description                                                   | Type                                                            | Mandatory | Default        |
| :--------------------------------------- | :------------------------------------------------------------ | :-------------------------------------------------------------- | :-------- | :------------- |
| <a id="yarn_resolve-name"></a>name       | A unique name for this target.                                | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required  |                |
| <a id="yarn_resolve-output"></a>output   | Package-relative output path                                  | String                                                          | optional  | "npm_data.bzl" |
| <a id="yarn_resolve-path"></a>path       | Package-relative path to package.json and yarn.lock directory | String                                                          | optional  | ""             |
| <a id="yarn_resolve-refresh"></a>refresh | Whether to refresh                                            | Boolean                                                         | optional  | True           |
