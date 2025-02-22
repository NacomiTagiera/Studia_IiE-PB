package com.example.todolist;

import androidx.fragment.app.Fragment;
import android.os.Bundle;

import java.util.UUID;

public class MainActivity extends SingleFragmentActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Override
  protected Fragment createFragment() {
    UUID taskId = (UUID)getIntent().getSerializableExtra(TaskListFragment.KEY_EXTRA_TASK_ID);
    return TaskFragment.newInstance(taskId);
  }
}