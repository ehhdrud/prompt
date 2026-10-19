import fs from 'fs-extra';
import path from 'path';
import { execSync } from 'child_process';

const REPO_URL = 'https://github.com/ehhdrud/prompt.git';
const BRANCH = 'main';
const SOURCE_DIRS = ['.claude', '.codex'];
const MIN_GIT_VERSION = '2.25.0';

function getGitVersion() {
  try {
    const output = execSync('git --version', { encoding: 'utf-8' });
    const match = output.match(/(\d+\.\d+\.\d+)/);
    return match ? match[1] : null;
  } catch {
    return null;
  }
}

function compareVersions(v1, v2) {
  const parts1 = v1.split('.').map(Number);
  const parts2 = v2.split('.').map(Number);
  for (let i = 0; i < 3; i++) {
    if (parts1[i] > parts2[i]) return 1;
    if (parts1[i] < parts2[i]) return -1;
  }
  return 0;
}

function supportsSparseCheckout() {
  const version = getGitVersion();
  if (!version) return false;
  return compareVersions(version, MIN_GIT_VERSION) >= 0;
}

export async function sync(options = {}) {
  const { dryRun = false } = options;
  const cwd = process.cwd();
  const tempDir = path.join(cwd, '.prompt-sync-temp');

  console.log('🔄 prompt 동기화 시작...\n');

  try {
    // 1. 임시 폴더에 레포 클론 (sparse checkout)
    console.log(`📥 원본 레포에서 ${SOURCE_DIRS.join(', ')} 폴더 다운로드...`);

    if (!dryRun) {
      // 임시 폴더 정리
      await fs.remove(tempDir);
      await fs.ensureDir(tempDir);

      // sparse checkout 시도, 실패하면 일반 clone으로 fallback
      let usedFallback = false;

      if (supportsSparseCheckout()) {
        try {
          // git sparse-checkout으로 프롬프트 폴더만 다운로드 (git 2.25+)
          execSync(`git clone --filter=blob:none --sparse "${REPO_URL}" "${tempDir}"`, {
            stdio: 'pipe'
          });
          execSync(`git -C "${tempDir}" sparse-checkout set ${SOURCE_DIRS.join(' ')}`, {
            stdio: 'pipe'
          });
          execSync(`git -C "${tempDir}" checkout ${BRANCH}`, {
            stdio: 'pipe'
          });
        } catch {
          // sparse checkout 실패 시 fallback
          usedFallback = true;
          await fs.remove(tempDir);
          await fs.ensureDir(tempDir);
        }
      } else {
        usedFallback = true;
      }

      if (usedFallback) {
        // 전체 clone 후 필요한 폴더만 사용
        console.log('  ℹ️  일반 clone 방식 사용');
        execSync(`git clone --depth 1 --branch ${BRANCH} "${REPO_URL}" "${tempDir}"`, {
          stdio: 'inherit'
        });
      }
    }

    if (!dryRun) {
      for (const sourceDirName of SOURCE_DIRS) {
        const sourceDir = path.join(tempDir, sourceDirName);
        const targetDir = path.join(cwd, sourceDirName);

        if (!await fs.pathExists(sourceDir)) {
          console.log(`\n📁 ${sourceDirName}/ 폴더 없음, 건너뜀`);
          continue;
        }

        const files = await getFiles(sourceDir);
        console.log(`\n📁 ${sourceDirName}/ 동기화 대상 파일 ${files.length}개:\n`);

        // 3. 파일 비교 및 복사 (텍스트 파일은 LF 정규화)
        for (const file of files) {
          const relativePath = path.relative(sourceDir, file);
          const targetPath = path.join(targetDir, relativePath);
          await fs.ensureDir(path.dirname(targetPath));

          let isNew = true;
          if (isTextFile(file)) {
            const content = (await fs.readFile(file, 'utf-8')).replace(/\r\n/g, '\n');
            const existing = await fs.readFile(targetPath, 'utf-8').catch(() => null);
            if (existing !== null) {
              isNew = false;
              if (content === existing) {
                console.log(`  [-] ${relativePath} (동일)`);
                continue;
              }
            }
            await fs.writeFile(targetPath, content, 'utf-8');
          } else {
            const srcBuf = await fs.readFile(file);
            const dstBuf = await fs.readFile(targetPath).catch(() => null);
            if (dstBuf !== null) {
              isNew = false;
              if (srcBuf.equals(dstBuf)) {
                console.log(`  [-] ${relativePath} (동일)`);
                continue;
              }
            }
            await fs.copy(file, targetPath, { overwrite: true });
          }
          console.log(isNew ? `  [+] ${relativePath} (신규)` : `  [*] ${relativePath} (업데이트)`);
        }
      }

      // 4. 임시 폴더 정리
      await fs.remove(tempDir);
    } else {
      console.log('  (dry-run 모드: 실제 파일 변경 없음)');
    }

    console.log('\n✨ 동기화 완료!\n');

    // 5. settings.local.json은 .gitignore에 추가 안내
    const gitignorePath = path.join(cwd, '.gitignore');
    const gitignoreContent = await fs.readFile(gitignorePath, 'utf-8').catch(() => '');

    if (!gitignoreContent.includes('settings.local.json')) {
      console.log('💡 팁: .gitignore에 다음 줄을 추가하세요:');
      console.log('   .claude/settings.local.json\n');
    }

  } catch (error) {
    console.error('❌ 동기화 실패:', error.message);
    await fs.remove(tempDir).catch(() => {});
    process.exit(1);
  }
}

const TEXT_EXTENSIONS = new Set(['.md', '.json', '.toml', '.yaml', '.yml', '.txt', '.js', '.ts', '.mjs', '.py', '.sh']);

function isTextFile(filePath) {
  return TEXT_EXTENSIONS.has(path.extname(filePath).toLowerCase());
}

async function getFiles(dir) {
  const files = [];
  const items = await fs.readdir(dir, { withFileTypes: true });

  for (const item of items) {
    const fullPath = path.join(dir, item.name);
    if (item.isDirectory()) {
      files.push(...await getFiles(fullPath));
    } else {
      files.push(fullPath);
    }
  }

  return files;
}
