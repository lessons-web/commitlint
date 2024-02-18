# Commitlint

## 配置 Commitlint

> 本文所涉及的 commit 提交规则验证依赖 Nodejs 环境，开发者根据自己的系统自行安装配置。

- 第一步：初始化仓库

无论是前端仓库，还是后端仓库，只要是代码类型的仓库，都可以。

- 第二步：初始化基本信息

```bash
npm init
```

- 第三步: 安装依赖

```bash
# 前置依赖
npm install --save-dev husky
# commitlint 相关依赖
npm install --save-dev @commitlint/cli @commitlint/config-conventional commitizen
```

- 第四步：配置 `commitlint.config.js`

```js
// 新建文件并键入如下内容
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "fix",
        "to",
        "feat",
        "docs",
        "style",
        "refactor",
        "test",
        "chore",
        "merge",
      ],
    ],
  },
};
```

- 第五步：运行前置命令，安装 `husky`

```json
{
  "scripts": {
    "prepare": "husky install"
  }
}
```

向 `package.json` 添加如下命令，然后运行 `npm run prepare`，命令是否运行成功可以查看仓库根目录是否增加了文件夹 `.husky`。

- 第六步：配置 `husky commit-msg` hooks

```bash
npx husky add .husky/commit-msg 'npx --no-install commitlint --edit $1'
```

命令行输入上述命令，查看 `.husky` 文件夹是否出现 `commit-msg` 文件，如果出现，表示配置成功，此后所有的提交信息都会进行规则验证，规则信息相关的内容可以通过 `commitlint.config.js` 进行更改。

## 配置 Changelog 相关

- 第一步：安装依赖

```bash
# changelog 相关依赖
npm install --save-dev compare-func conventional-changelog conventional-changelog-cli conventional-changelog-custom-config
```

- 第二步：配置 `changelog.config.js`

```js
// 新建文件并键入如下内容
const compareFunc = require("compare-func");

module.exports = {
  writerOpts: {
    transform: (commit, context) => {
      let discard = true;
      const issues = [];

      commit.notes.forEach((note) => {
        note.title = "BREAKING CHANGES";
        discard = false;
      });
      if (commit.type === "feat") {
        commit.type = "✨ Features | 新功能";
      } else if (commit.type === "fix") {
        commit.type = "🐛 Bug Fixes | Bug 修复";
      } else if (commit.type === "perf") {
        commit.type = "⚡ Performance Improvements | 性能优化";
      } else if (commit.type === "revert" || commit.revert) {
        commit.type = "⏪ Reverts | 回退";
      } else if (discard) {
        return;
      } else if (commit.type === "docs") {
        commit.type = "📝 Documentation | 文档";
      } else if (commit.type === "style") {
        commit.type = "💄 Styles | 风格";
      } else if (commit.type === "refactor") {
        commit.type = "♻ Code Refactoring | 代码重构";
      } else if (commit.type === "test") {
        commit.type = "✅ Tests | 测试";
      } else if (commit.type === "build") {
        commit.type = "👷‍ Build System | 构建";
      } else if (commit.type === "ci") {
        commit.type = "🔧 Continuous Integration | CI 配置";
      } else if (commit.type === "chore") {
        commit.type = "🎫 Chores | 框架更新";
      }

      if (commit.scope === "*") {
        commit.scope = "";
      }

      if (typeof commit.hash === "string") {
        commit.hash = commit.hash.substring(0, 7);
      }

      if (typeof commit.subject === "string") {
        let url = context.repository
          ? `${context.host}/${context.owner}/${context.repository}`
          : context.repoUrl;

        if (url) {
          url = `${url}/issues/`;
          // Issue URLs.
          commit.subject = commit.subject.replace(/#([0-9]+)/g, (_, issue) => {
            issues.push(issue);
            return `[#${issue}](${url}${issue})`;
          });
        }

        if (context.host) {
          // User URLs.
          commit.subject = commit.subject.replace(
            /\B@([a-z0-9](?:-?[a-z0-9/]){0,38})/g,
            (_, username) => {
              if (username.includes("/")) {
                return `@${username}`;
              }
              return `[@${username}](${context.host}/${username})`;
            }
          );
        }
      }

      // remove references that already appear in the subject
      commit.references = commit.references.filter((reference) => {
        if (issues.indexOf(reference.issue) === -1) {
          return true;
        }
        return false;
      });
      return commit;
    },
    groupBy: "type",
    commitGroupsSort: "title",
    commitsSort: ["scope", "subject"],
    noteGroupsSort: "title",
    notesSort: compareFunc,
  },
};
```

- 第三步：`package.json` 添加指令

```json
{
  "scripts": {
    "changelog": "conventional-changelog -p custom-config -i CHANGELOG.md -s -r 0  -n ./changelog.config.js"
  }
}
```

至此，自动生成 Changelog 文件的配置就完成了，可以运行 `npm run changlog` 命令自动生成 changelog 文件。

## branch rules

| 分支类型     | 示例                                | 分支含义                                                                                                                                                               |
| ------------ | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 主干分支     | main/master                         | 一个应用对应一个仓库对应一个主干分支，此分支代码用于生产环境的发布，不允许再此分支上进行代码的推送，只允许通过 Merge Request 在管理员 Code Review 通过后合并到主分支。 |
| 业务开发分支 | feature/single<br />feature/cluster | 需求开发分支，一般对应一个新的业务需求的开发。                                                                                                                         |
| 业务修复分支 | fix/data-shake                      | 修复分支，一般对应已经合并到主干的代码在线上或者其他环境出现问题，紧急切新分支进行修复。                                                                               |
| 文档类型分支 | docs/add-intro                      | 文档类型分支，一般不涉及代码层面变更，只是在开发完成后对现有功能进行文档书写或者对接口补充注释等等。                                                                   |

## Commit Rules

| Commit 类型 | 描述                                                                                                                                               | 示例                                                                            |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| feat:       | 新功能，对应 feature                                                                                                                               | feat: add single page<br />feat: add siderbar panel<br />feat: 新增数据详情面板 |
| fix:        | 修复 bug，可以是 QA 发现的，也可以是自测发现的                                                                                                     | fix: 修复数据抖动<br />fix: 修复 RTSP 推流无法显示问题                          |
| to:         | 修复 bug，与 Fix 不同，Fix 是修复完成，to 是本次提交没有修复完成，但是完成了一部份修复，一般在没有办法在本次提交修复但是又必须进行提交的时候使用。 | to: RTSP 推流无法显示<br />to: 按钮切换逻辑                                     |
| style:      | 样式代码修改，不涉及到业务逻辑，单纯的样式修改                                                                                                     | style: 适配移动端<br />style: 首页文字颜色优化                                  |
| docs:       | 文档类型修改，不涉及到业务逻辑                                                                                                                     | docs: update readme<br />docs: 新增使用文档                                     |
| test:       | 测试逻辑                                                                                                                                           | test: 测试 MQTT Hooks                                                           |

> 更多内容，详见 DOC.md 文档

> 20240218_6080 公开课
